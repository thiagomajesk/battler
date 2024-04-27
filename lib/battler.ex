defmodule Battler do
  @moduledoc """
  Implements a CTB (Charge Time Battle) based battler.

  The battle events happen in the following order:

  - battle_started: When all actors have joined and are ready
  - charging_phase: Charges all actors involved in combat
  - turn_started: When a given actor is ready to act
  - combat_phase: Actors engaged in combat fight
  - cleanup_phase: Resolve outstanding effects on all actors
  - battle_ended: When the victory condition is reached
  """
  use GenServer

  require Logger

  alias Battler.State
  alias Battler.Combat
  alias Battler.Skill
  alias Battler.Actor

  defdelegate get_current_round(state), to: State
  defdelegate list_possible_targets(state), to: State
  defdelegate list_selected_targets(state), to: State
  defdelegate actor_ready?(state, actor), to: State
  defdelegate actor_dead?(actor), to: Actor, as: :dead?
  defdelegate ally_can_target?(state, actor), to: State
  defdelegate enemy_can_target?(state, actor), to: State
  defdelegate selected_by_ally?(state, actor), to: State
  defdelegate selected_by_enemy?(state, actor), to: State
  defdelegate targets_acquired?(state), to: State

  @doc """
  Stats a battle between the allies and enemies.
  Expects an unique id to be given to identify the battle.
  """
  def start_link(%{id: id, actors: actors}) do
    via = {:via, Registry, {Battler.BattlerRegistry, to_string(id)}}
    args = %{actors: actors, timescale: 1000, turn_duration: 20000}
    GenServer.start_link(__MODULE__, args, name: via)
  end

  @doc """
  Finds a battle currently running.
  """
  def find_battle(battler_id) do
    case Registry.lookup(Battler.BattlerRegistry, battler_id) do
      [{battler_id, _}] -> battler_id
      _ -> raise "Failed to find battler for #{battler_id}"
    end
  end

  @doc """
  Subscribes to changes in the state of the battle.
  """
  def subscribe() do
    Phoenix.PubSub.subscribe(Battler.PubSub, "battler")
  end

  @doc """
  Asks the battler for its current state.
  """
  def fetch_state(battler_pid) do
    GenServer.call(battler_pid, :fetch_state)
  end

  def use_skill(battler_pid, skill_id) do
    GenServer.call(battler_pid, {:use_skill, skill_id})
  end

  def select_target(battler_pid, actor_id) do
    GenServer.call(battler_pid, {:select_target, actor_id})
  end

  def confirm_action(battler_pid) do
    GenServer.call(battler_pid, :confirm_action)
  end

  @impl true
  def init(args) do
    {actors, args} = Map.pop!(args, :actors)
    state = State.new(actors, Enum.into(args, []))
    {:ok, push_timed_event(state, :battle_started)}
  end

  @impl true
  def handle_call(:fetch_state, _from, state) do
    {:reply, State.export(state), state}
  end

  @impl true
  def handle_call({:use_skill, skill_id}, _from, state) do
    with {:ok, actor} <- check_active_actor(state),
         {:ok, skill} <- check_actor_has_skill(actor, skill_id),
         {:ok, state} <- do_select_action(state, skill) do
      {:reply, {:ok, State.export(state)}, state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:select_target, target_id}, _from, state) do
    with {:ok, _action} <- check_selected_action(state),
         {:ok, target} <- check_possible_target(state, target_id),
         {:ok, state} <- do_select_target(state, target) do
      {:reply, {:ok, State.export(state)}, state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(:confirm_action, _from, state) do
    with {:ok, actor} <- check_active_actor(state),
         {:ok, action} <- check_selected_action(state),
         {:ok, targets} <- check_selected_targets(state),
         {:ok, state} <- do_execute_action(state, actor, action, targets) do
      # We want to be able to animate the skills on the UI imediatelly after
      # something happens and before we actually sync the state with clients.
      # TODO: Pass the necessary metadata about the effect to the notification
      state = notify_event(state, :effect_animation, %{})

      # Broadcast the changes to all the clients, this might be redundat for the client
      # that is executing the action because it will already get the updated state after this.
      state = notify_change(state, :action_executed)

      # We get the updated active actor from the state and check if its tired (zeroed CP).
      # If the actor can't keep acting, we want to end its the turn automatically.
      state =
        if Actor.tired?(state.active_actor),
          do: push_event(state, :end_turn),
          else: state

      {:reply, {:ok, State.export(state)}, state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info(:battle_started, state) do
    {:noreply,
     state
     |> notify_change(:battle_started)
     |> push_event(:charging_phase)}
  end

  @impl true
  def handle_info(:charging_phase, state) do
    # We always want to check if we have an actor ready first and only charge others if not.
    # This will avoid race conditions where multiple actors with maxed cp could act at the same time.
    # In this case, this means that we end up prioritizing actors that haven't acted yet before charging.
    case State.find_next_actor(state) do
      nil ->
        state = State.recover_actors_charges(state)
        state = notify_change(state, :charging_phase)
        {:noreply, push_timed_event(state, :charging_phase)}

      actor ->
        state = State.put_active_actor(state, actor)
        {:noreply, push_event(state, :turn_started)}
    end
  end

  @impl true
  def handle_info(:turn_started, state) do
    state =
      Map.update!(state, :turn_expiration, fn ref ->
        # We schedule a event that will halt the current actor turn if it has taken
        # more time that it was suppose to. We also try to cancel any pending events.
        if is_pid(ref) and Process.alive?(ref), do: Process.cancel_timer(ref)
        Process.send_after(self(), {:halt_turn, state.turn_count}, state.turn_duration)
      end)

    case state.active_actor do
      %{ai?: true} ->
        {:noreply, notify_change(state, :turn_started)}

      %{ai?: false} ->
        {:noreply, notify_change(state, :turn_started)}
    end
  end

  @impl true
  def handle_info({:halt_turn, turn_count}, state) do
    # If we are still on the same turn as before, we'll try to halt it
    if state.active_actor != nil and turn_count == state.turn_count do
      # If the player doesn't take action, we are going to penalize it by zeroing its CP.
      state = State.change_actors(state, %{cp: 0}, &(&1.id == state.active_actor.id))
      {:noreply, push_event(state, :end_turn)}
    else
      {:noreply, state}
    end
  end

  def handle_info(:end_turn, state) do
    state = State.put_active_actor(state, nil)
    state = notify_change(state, :turn_ended)
    {:noreply, push_timed_event(state, :charging_phase)}
  end

  defp check_active_actor(%State{} = state) do
    case state.active_actor do
      nil -> {:error, "No active actor yet"}
      actor -> {:ok, actor}
    end
  end

  defp check_actor_has_skill(actor, skill_id) do
    case Enum.find(actor.skills, &(&1.id == skill_id)) do
      nil -> {:error, "Skill does not exist"}
      skill -> {:ok, skill}
    end
  end

  defp check_selected_action(%State{} = state) do
    case state.selected_action do
      nil -> {:error, "No action selected yet"}
      action -> {:ok, action}
    end
  end

  defp check_selected_targets(%State{} = state) do
    case list_selected_targets(state) do
      [] -> {:error, "No targets selected yet"}
      targets -> {:ok, targets}
    end
  end

  defp check_possible_target(%State{} = state, actor_id) do
    possible_targets = State.list_possible_targets(state)

    case Enum.find(possible_targets, &(&1.id == actor_id)) do
      nil -> {:error, "Actor is not a possible target"}
      actor -> {:ok, actor}
    end
  end

  defp do_select_action(%State{} = state, action) do
    cond do
      state.selected_action == nil ->
        {:ok, State.put_selected_action(state, action)}

      state.selected_action.id == action.id ->
        {:ok, State.put_selected_action(state, nil)}

      true ->
        {:ok, State.put_selected_action(state, action)}
    end
  end

  defp do_select_target(%State{} = state, target) do
    cond do
      state.targets_locked? ->
        {:error, "Targets are currently locked"}

      State.selected_target?(state, target) ->
        {:ok, State.put_selected_target(state, nil)}

      true ->
        {:ok, State.put_selected_target(state, target)}
    end
  end

  defp do_execute_action(%State{} = state, %Actor{} = actor, %Skill{} = skill, targets) do
    targets = Combat.apply_skill_effects(skill, targets)

    actor = %{
      actor
      | cp: max(actor.cp - skill.cp_cost, 0),
        mp: max(actor.mp - skill.mp_cost, 0)
    }

    # The easiest way of clearing state is resetting the
    # active actor after it has finished executing its latest action.
    state = State.put_active_actor(state, actor)
    state = State.replace_actors(state, [actor | targets])

    {:ok, state}
  end

  defp notify_change(%State{} = state, event) do
    notify_event(state, event, State.export(state))
  end

  defp notify_event(%State{} = state, event, info) do
    case notify({:battler, event, info}) do
      :ok -> log_syncs(state, event)
      {:error, _reason} -> state
    end
  end

  defp notify(message) do
    Phoenix.PubSub.broadcast(Battler.PubSub, "battler", message)
  end

  defp push_timed_event(state, event) do
    push_event(state, event, state.timescale)
  end

  defp push_event(state, event, time \\ 0) do
    Process.send_after(self(), event, time)
    Map.update!(state, :__events__, &[event | &1])
  end

  defp log_syncs(state, event) do
    timestamp = :os.system_time()
    Map.update!(state, :__syncs__, &[{event, timestamp} | &1])
  end
end
