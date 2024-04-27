defmodule BattlerWeb.BattleRoomLive do
  use BattlerWeb, :live_view

  require Logger
  import BattlerWeb.Components.BattleUI

  def mount(_params, _session, socket) do
    {:ok, battler_pid} = find_or_start_battle()

    socket =
      socket
      |> assign(:battler_pid, battler_pid)
      |> assign_state(Battler.fetch_state(battler_pid))

    # Start the combat and go through all the phases
    if connected?(socket), do: Battler.subscribe()

    {:ok, socket}
  end

  def handle_info({:battler, :effect_animation, _params}, socket) do
    {:noreply, socket}
  end

  def handle_info({:battler, battle_event, state}, socket) do
    pid = socket.assigns.battler_pid
    event = String.upcase(Phoenix.Naming.humanize(battle_event))
    Logger.info("#{event} \t ON #{inspect(self())} FROM #{inspect(pid)}")
    {:noreply, assign_state(socket, state)}
  end

  def handle_event("use-skill", %{"skill" => skill_id}, socket) do
    battler_pid = socket.assigns.battler_pid

    case Battler.use_skill(battler_pid, skill_id) do
      {:ok, state} ->
        {:noreply, assign_state(socket, state)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_event("select-target", %{"target" => target_id}, socket) do
    battler_pid = socket.assigns.battler_pid

    case Battler.select_target(battler_pid, target_id) do
      {:ok, state} ->
        {:noreply, assign_state(socket, state)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_event("confirm-action", _params, socket) do
    battler_pid = socket.assigns.battler_pid

    case Battler.confirm_action(battler_pid) do
      {:ok, state} ->
        {:noreply, assign_state(socket, state)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_event("inspect-actor", %{"actor" => actor_id}, socket) do
    actor = Enum.find(socket.assigns.state.actors, &(&1.id == actor_id))

    {:noreply,
     put_flash(socket, :info, """
     You see #{actor.name}
     HP: #{actor.hp}/#{actor.max_hp}
     MP: #{actor.mp}/#{actor.max_mp}
     CP: #{actor.cp}/#{actor.max_cp}
     """)}
  end

  defp assign_state(socket, new_state) do
    new_hash = new_state.__hash__

    case socket.assigns[:state] do
      %{__hash__: ^new_hash} ->
        Logger.info("No change in state, ignoring \t #{new_hash}")
        socket

      _current_state ->
        parties = Enum.group_by(new_state.actors, & &1.party)
        assign(socket, Map.merge(%{state: new_state}, parties))
    end
  end

  defp find_or_start_battle() do
    allies = Battler.Fake.list_allies()
    enemies = Battler.Fake.list_enemies()

    args = %{
      id: :battle_identifier,
      actors: allies ++ enemies
    }

    case Battler.start_link(args) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  attr :state, Battler.State, required: true

  defp header_panel(assigns) do
    ~H"""
    <div class="h-[48px] flex w-full items-center">
      <div :if={@state.active_actor} class="flex items-center gap-4">
        <.actor_portrait_preview actor={@state.active_actor} />
        <span class="font-medium text-white">
          <%= "#{@state.active_actor.name}'s turn" %>
        </span>
      </div>
      <div class="ml-auto text-white" data-auto-animate>
        <div
          :if={@state.active_actor}
          class="flex items-center gap-2 rounded-lg bg-gray-900 px-2 py-1 shadow"
        >
          <small class="font-medium uppercase">Round</small>
          <span class="tabular-nums"><%= Battler.get_current_round(@state) %></span>
          <.countdown ref={@state.turn_expiration} />
        </div>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :actors, :list, required: true
  attr :state, Battler.State, required: true

  defp party_grid(assigns) do
    ~H"""
    <div id={@id} class="flex grid grid-cols-4 gap-1 md:gap-2" data-auto-animate>
      <.actor_card :for={actor <- @actors} actor={actor} state={@state} />
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global, default: %{}
  slot :inner_block, required: true

  defp container(assigns) do
    ~H"""
    <div class={["container mx-auto flex w-full lg:max-w-4xl", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
