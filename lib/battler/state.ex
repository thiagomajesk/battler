defmodule Battler.State do
  @enforce_keys [:actors, :timescale, :turn_duration]
  defstruct __hash__: nil,
            __events__: [],
            __syncs__: [],
            timescale: nil,
            actors: [],
            turn_count: 0,
            turn_duration: 0,
            turn_expiration: nil,
            active_actor: nil,
            selected_action: nil,
            targets_locked?: false,
            possible_targets: MapSet.new(),
            selected_targets: MapSet.new()

  alias __MODULE__
  alias Battler.Actor

  @doc false
  def new(actors, opts \\ []) do
    timescale = Keyword.get(opts, :timescale, 1000)
    turn_duration = Keyword.get(opts, :turn_duration, 60000)
    actors = Enum.sort_by(actors, & &1.spd, :desc)
    %State{actors: actors, turn_duration: turn_duration, timescale: timescale}
  end

  @doc false
  def export(%State{} = state) do
    keys_to_ignore = [:__events__, :__syncs__, :__hash__]
    changes = Map.drop(state, keys_to_ignore)
    hash = to_string(:erlang.phash2(changes))
    Map.put(changes, :__hash__, Base.encode64(hash))
  end

  @doc """
  Finds the next actor that is ready to act.
  """
  def find_next_actor(%State{} = state) do
    Enum.find(state.actors, fn actor ->
      Actor.ready?(actor) and not Actor.dead?(actor)
    end)
  end

  @doc """
  Returns the current round number.
  """
  def get_current_round(%State{} = state) do
    ceil(state.turn_count / length(state.actors))
  end

  @doc """
  List all the actors that are possible targets for the current action.
  """
  def list_possible_targets(%State{} = state) do
    Enum.filter(state.actors, &possible_target?(state, &1))
  end

  @doc """
  List all the actors that were selected as targets for the current action.
  """
  def list_selected_targets(%State{} = state) do
    Enum.filter(state.actors, &selected_target?(state, &1))
  end

  @doc """
  Returns whether the given actor is ready to act or not.
  """
  def actor_ready?(%State{} = state, %Actor{} = actor) do
    state.active_actor != nil and Actor.self?(state.active_actor, actor)
  end

  @doc """
  Returns whether the given actor is a possible target for the current action.
  """
  def possible_target?(%State{} = state, %Actor{} = actor) do
    MapSet.member?(state.possible_targets, actor.id)
  end

  @doc """
  Returns whether the given actor is a selected target for the current action.
  """
  def selected_target?(%State{} = state, %Actor{} = actor) do
    MapSet.member?(state.selected_targets, actor.id)
  end

  @doc """
  Return whether any targets been acquired so far.
  """
  def targets_acquired?(%State{} = state) do
    MapSet.size(state.selected_targets) > 0
  end

  @doc """
  Return whether the given actor can be target by an ally or not.
  """
  def ally_can_target?(%State{} = state, %Actor{} = actor) do
    state.active_actor != nil and
      Actor.allies?(state.active_actor, actor) and
      possible_target?(state, actor)
  end

  @doc """
  Return whether the given actor can be target by an enemy or not.
  """
  def enemy_can_target?(%State{} = state, %Actor{} = actor) do
    state.active_actor != nil and
      Actor.enemies?(state.active_actor, actor) and
      possible_target?(state, actor)
  end

  @doc """
  Return whether the given actor has been selected as target by an ally or not.
  """
  def selected_by_ally?(%State{} = state, %Actor{} = actor) do
    state.active_actor != nil and
      Actor.allies?(state.active_actor, actor) and
      selected_target?(state, actor)
  end

  @doc """
  Return whether the given actor has been selected as target by an enemy or not.
  """
  def selected_by_enemy?(%State{} = state, %Actor{} = actor) do
    state.active_actor != nil and
      Actor.enemies?(state.active_actor, actor) and
      selected_target?(state, actor)
  end

  @doc """
  Sets the given actor as the current active actor and increases the turn count.
  If `nil` is passed, removes the active actor and resets the state (actions and targets).
  When the given actor is already active, resets the state and keeps the active actor.
  """
  def put_active_actor(%State{} = state, actor) do
    case {state.active_actor, actor} do
      {^actor, _} ->
        state
        |> Map.put(:selected_action, nil)
        |> Map.put(:possible_targets, MapSet.new())
        |> Map.put(:selected_targets, MapSet.new())
        |> Map.put(:targets_locked?, false)
        |> Map.put(:active_actor, actor)

      {_, nil} ->
        state
        |> Map.put(:selected_action, nil)
        |> Map.put(:possible_targets, MapSet.new())
        |> Map.put(:selected_targets, MapSet.new())
        |> Map.put(:targets_locked?, false)
        |> Map.put(:active_actor, nil)

      {_, actor} ->
        state
        |> Map.put(:selected_action, nil)
        |> Map.put(:possible_targets, MapSet.new())
        |> Map.put(:selected_targets, MapSet.new())
        |> Map.put(:targets_locked?, false)
        |> Map.put(:active_actor, actor)
        |> Map.update!(:turn_count, &(&1 + 1))
    end
  end

  @doc """
  Updates the currently selected target.
  """
  def put_selected_target(%State{} = state, actor) do
    case actor do
      nil ->
        Map.put(state, :selected_targets, MapSet.new())

      %{id: actor_id} ->
        Map.put(state, :selected_targets, MapSet.new([actor_id]))
    end
  end

  @doc """
  Updates the currently selected action with the given skill.
  If the selected action is the same, it removes it (aka cancels it).
  """
  def put_selected_action(%State{} = state, action) do
    case action do
      nil ->
        state
        |> Map.put(:selected_action, nil)
        |> Map.put(:possible_targets, MapSet.new())
        |> Map.put(:selected_targets, MapSet.new())
        |> Map.put(:targets_locked?, false)

      %{target: :self} ->
        targets =
          filter_targets(state, fn actor ->
            Actor.self?(actor, state.active_actor)
          end)

        state
        |> Map.put(:selected_action, action)
        |> Map.put(:possible_targets, targets)
        |> Map.put(:selected_targets, targets)
        |> Map.put(:targets_locked?, true)

      %{target: :ally} ->
        targets =
          filter_targets(state, fn actor ->
            Actor.allies?(state.active_actor, actor) and
              not Actor.dead?(actor)
          end)

        state
        |> Map.put(:selected_action, action)
        |> Map.put(:possible_targets, targets)
        |> Map.put(:selected_targets, MapSet.new())
        |> Map.put(:targets_locked?, false)

      %{target: :enemy} ->
        targets =
          filter_targets(state, fn actor ->
            Actor.enemies?(actor, state.active_actor) and
              not Actor.dead?(actor)
          end)

        state
        |> Map.put(:selected_action, action)
        |> Map.put(:possible_targets, targets)
        |> Map.put(:selected_targets, MapSet.new())
        |> Map.put(:targets_locked?, false)

      %{target: :allies} ->
        targets =
          filter_targets(state, fn actor ->
            Actor.allies?(actor, state.active_actor) and
              not Actor.self?(actor, state.active_actor) and
              not Actor.dead?(actor)
          end)

        state
        |> Map.put(:selected_action, action)
        |> Map.put(:possible_targets, targets)
        |> Map.put(:selected_targets, targets)
        |> Map.put(:targets_locked?, true)

      %{target: :enemies} ->
        targets =
          filter_targets(state, fn actor ->
            Actor.enemies?(actor, state.active_actor) and
              not Actor.self?(actor, state.active_actor) and
              not Actor.dead?(actor)
          end)

        state
        |> Map.put(:selected_action, action)
        |> Map.put(:possible_targets, targets)
        |> Map.put(:selected_targets, targets)
        |> Map.put(:targets_locked?, true)

      %{target: :party} ->
        targets =
          filter_targets(state, fn actor ->
            Actor.allies?(actor.party, state.active_actor) and
              not Actor.dead?(actor)
          end)

        state
        |> Map.put(:selected_action, action)
        |> Map.put(:possible_targets, targets)
        |> Map.put(:selected_targets, targets)
        |> Map.put(:targets_locked?, true)

      %{target: :dead_ally} ->
        targets =
          filter_targets(state, fn actor ->
            Actor.allies?(actor, state.active_actor) and
              Actor.dead?(actor)
          end)

        state
        |> Map.put(:selected_action, action)
        |> Map.put(:possible_targets, targets)
        |> Map.put(:selected_targets, MapSet.new())
        |> Map.put(:targets_locked?, false)

      %{target: :dead_enemy} ->
        targets =
          filter_targets(state, fn actor ->
            Actor.enemies?(actor, state.active_actor) and
              Actor.dead?(actor)
          end)

        state
        |> Map.put(:selected_action, action)
        |> Map.put(:possible_targets, targets)
        |> Map.put(:selected_targets, MapSet.new())
        |> Map.put(:targets_locked?, false)
    end
  end

  @doc """
  Recovers the charges for all actors in the battle.
  """
  def recover_actors_charges(%State{} = state) do
    Map.update!(state, :actors, fn actors ->
      Enum.map(actors, &Actor.recover_charge/1)
    end)
  end

  @doc """
  Push changes to the actors returned by the given function.
  """
  def change_actors(%State{} = state, changes, fun)
      when is_function(fun, 1) do
    Map.update!(state, :actors, fn actors ->
      Enum.map(actors, fn actor ->
        if fun.(actor),
          do: Map.merge(actor, changes),
          else: actor
      end)
    end)
  end

  def replace_actors(%State{} = state, new_actors) do
    lookup = Map.new(new_actors, &{&1.id, &1})

    Map.update!(state, :actors, fn old_actors ->
      Enum.map(old_actors, fn old_actor ->
        if new_actor = lookup[old_actor.id],
          do: new_actor,
          else: old_actor
      end)
    end)
  end

  defp filter_targets(%State{actors: actors}, fun)
       when is_function(fun, 1) do
    actors
    |> Enum.filter(fun)
    |> Enum.map(& &1.id)
    |> MapSet.new()
  end
end
