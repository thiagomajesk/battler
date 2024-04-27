defmodule BattlerWeb.Components.BattleUI do
  use BattlerWeb, :component

  attr :actor, Battler.Actor, required: true
  attr :state, Battler.State, required: true

  def actor_card(assigns) do
    assigns =
      assign_new(assigns, :click_attrs, fn %{actor: actor, state: state} ->
        cond do
          (Battler.ally_can_target?(state, actor) or
             Battler.enemy_can_target?(state, actor)) and
              not state.targets_locked? ->
            [
              {"phx-click", "select-target"},
              {"phx-value-target", actor.id}
            ]

          true ->
            [
              {"phx-click", "inspect-actor"},
              {"phx-value-actor", actor.id}
            ]
        end
      end)

    ~H"""
    <div
      id={"#{@actor.id}-wrapper"}
      class="relative flex cursor-pointer select-none flex-col"
      {@click_attrs}
    >
      <.arrow
        :if={Battler.actor_ready?(@state, @actor)}
        class="absolute z-10 right-0 left-0 mx-auto size-6 md:size-8 animate-bounce"
      />

      <span class="absolute top-2 right-2 z-10 flex items-center gap-1 text-white">
        <UI.Media.icon
          :if={Battler.selected_by_ally?(@state, @actor)}
          name="target"
          class="text-emerald-500"
          size={18}
        />
        <UI.Media.icon
          :if={Battler.selected_by_enemy?(@state, @actor)}
          name="swords"
          class="text-rose-500"
          size={18}
        />
        <UI.Media.icon :if={Battler.actor_dead?(@actor)} name="skull" class="text-gray-500" size={18} />
      </span>
      <div
        id={@actor.id}
        data-ally-can-target={Battler.ally_can_target?(@state, @actor)}
        data-enemy-can-target={Battler.enemy_can_target?(@state, @actor)}
        data-selected-by-ally={Battler.selected_by_ally?(@state, @actor)}
        data-selected-by-enemy={Battler.selected_by_enemy?(@state, @actor)}
        data-actor-dead={Battler.actor_dead?(@actor)}
        class={[
          "bg-gray-950/75 flex flex-col rounded-lg border-2 border-transparent p-2 backdrop-blur transition-all md:p-4 lg:p-6",
          "data-[ally-can-target]:!border-emerald-500 data-[enemy-can-target]:!border-rose-500",
          "data-[selected-by-ally]:!bg-emerald-950/75 data-[selected-by-ally]:shadow-emerald-500/30 data-[selected-by-ally]:shadow-xl",
          "data-[selected-by-enemy]:!bg-rose-950/75 data-[selected-by-enemy]:shadow-rose-500/30 data-[selected-by-enemy]:shadow-xl",
          "data-[actor-dead]:grayscale"
        ]}
      >
        <span class="mb-1 text-center font-semibold text-white">
          <%= @actor.name %>
        </span>
        <img
          draggable="false"
          src={~p"/images/actors/#{@actor.icon}"}
          class="mb-4 h-auto max-w-full self-center"
        />
        <div class="flex flex-col space-y-2">
          <div class="flex flex-col space-y-1">
            <.resource_progress
              id={"#{@actor.id}-hp-progress"}
              value={@actor.hp}
              max_value={@actor.max_hp}
              variant="red"
              timescale={@state.timescale}
            />
            <.resource_progress
              id={"#{@actor.id}-mp-progress"}
              value={@actor.mp}
              max_value={@actor.max_mp}
              variant="blue"
              timescale={@state.timescale}
            />
            <.resource_progress
              id={"#{@actor.id}-cp-progress"}
              value={@actor.cp}
              max_value={@actor.max_cp}
              variant="amber"
              timescale={@state.timescale}
            />
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :state, Battler.State, required: true

  def promp_panel(assigns) do
    ~H"""
    <section
      :if={@state.selected_action}
      class="bg-gray-950/75 flex w-full flex-col justify-between rounded-lg p-4 text-white shadow-lg backdrop-blur"
    >
      <header class="flex w-full items-center justify-between">
        <h2 class="text-lg font-medium"><%= @state.selected_action.name %></h2>
        <div class="flex items-center gap-2">
          <span class="me-2 flex items-center rounded bg-gray-950 px-2.5 py-0.5 text-sm font-medium text-gray-300">
            <UI.Media.gicon name="water-drop" size={16} class="text-amber-500" />
            <%= "#{@state.selected_action.cp_cost} CP" %>
          </span>
          <span class="me-2 flex items-center rounded bg-gray-950 px-2.5 py-0.5 text-sm font-medium text-gray-300">
            <UI.Media.gicon name="water-drop" size={16} class="text-blue-500" />
            <%= "#{@state.selected_action.mp_cost} MP" %>
          </span>
        </div>
      </header>
      <p class="mb-4 text-gray-400">
        <%= @state.selected_action.description %>
      </p>
      <div class="flex w-full items-center justify-between">
        <div class="flex animate-pulse items-center gap-1">
          <.actor_portrait_preview
            :for={actor <- Battler.list_selected_targets(@state)}
            actor={actor}
          />
        </div>
        <button
          :if={Battler.targets_acquired?(@state)}
          type="button"
          phx-click="confirm-action"
          class={[
            "flex items-center gap-1 self-center rounded-lg bg-gradient-to-br from-amber-600 to-yellow-500 px-5 py-2.5 text-center text-sm font-medium text-white hover:bg-gradient-to-bl"
          ]}
        >
          Confirm action
        </button>
      </div>
    </section>
    """
  end

  attr :state, Battler.State, required: true

  def footer_panel(assigns) do
    ~H"""
    <div class="flex w-full items-center justify-between gap-4">
      <div class="grid grid-cols-4 gap-2">
        <div
          :for={skill <- @state.active_actor.skills}
          class={[
            "rounded-lg border-2 border-white p-1 hover:cursor-pointer hover:border-amber-500",
            @state.selected_action && @state.selected_action.id == skill.id && "!border-amber-500"
          ]}
          title={skill.name}
          phx-click="use-skill"
          phx-value-skill={skill.id}
        >
          <img draggable="false" src={"/images/skills/#{skill.icon}"} class="size-6 md:size-12" />
        </div>
      </div>
      <div class="flex items-center gap-2">
        <button
          type="button"
          title="Finish"
          class="size-6 flex h-full items-center justify-center gap-1 rounded border border-gray-800 bg-gray-900 px-2 py-1 text-sm font-medium text-white hover:bg-gray-800 focus:outline-none focus:ring-4 focus:ring-gray-300 md:size-12"
        >
          <span class="flex items-center">
            <UI.Media.icon name="next-plan-rounded" size={24} />
          </span>
        </button>
        <button
          type="button"
          title="Surrender"
          class="size-6 flex h-full items-center justify-center gap-1 rounded border border-gray-800 bg-gray-900 px-2 py-1 text-sm font-medium text-white hover:bg-gray-800 focus:outline-none focus:ring-4 focus:ring-gray-300 md:size-12"
        >
          <span class="flex items-center">
            <UI.Media.icon name="flag-circle-rounded" size={24} />
          </span>
        </button>
      </div>
    </div>
    """
  end

  attr :rest, :global

  def arrow(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="-38.63 -38.63 463.52 463.52"
      xml:space="preserve"
      fill="#000"
      {@rest}
    >
      <path
        d="m0 96.879 193.129 192.5 193.128-192.5z"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke="#fff"
        stroke-width="38.626"
      />
      <path d="m0 96.879 193.129 192.5 193.128-192.5z" />
    </svg>
    """
  end

  attr :id, :string, required: true
  attr :value, :integer, required: true
  attr :max_value, :integer, required: true
  attr :variant, :string, required: true
  attr :timescale, :integer, required: true

  def resource_progress(assigns) do
    assigns =
      assign_new(assigns, :percentage, fn assigns ->
        assigns.value / assigns.max_value * 100
      end)

    assigns =
      assign_new(assigns, :main_progress_classes, fn
        %{variant: "red"} -> "from-red-700 via-red-500 to-red-400"
        %{variant: "blue"} -> "from-blue-700 via-blue-500 to-blue-400"
        %{variant: "amber"} -> "from-amber-700 via-amber-500 to-amber-400"
      end)

    assigns =
      assign_new(assigns, :trail_progress_classes, fn
        %{variant: "red"} -> "from-red-50 via-red-100 to-red-200"
        %{variant: "blue"} -> "from-blue-50 via-blue-100 to-blue-200"
        %{variant: "amber"} -> "from-amber-50 via-amber-100 to-amber-200"
      end)

    assigns =
      assign_props(assigns, fn assigns ->
        %{
          value: assigns.percentage,
          main_id: "#{assigns.id}-main",
          trail_id: "#{assigns.id}-trail",
          delay: assigns.timescale / 2
        }
      end)

    ~H"""
    <div
      id={@id}
      phx-hook="Progress"
      data-props={@props}
      phx-update="ignore"
      class="relative h-3 w-full rounded-sm bg-black outline outline-1 outline-black"
      title={"#{@value}/#{@max_value}"}
    >
      <div
        id={"#{@id}-trail"}
        class={[
          "absolute flex h-full items-center rounded-sm bg-gradient-to-r",
          @trail_progress_classes,
          "transition-[width] duration-500 ease-out"
        ]}
      >
      </div>
      <div
        id={"#{@id}-main"}
        class={[
          "absolute flex h-full items-center rounded-sm bg-gradient-to-r",
          @main_progress_classes,
          "transition-[width] duration-500 ease-out"
        ]}
      >
      </div>
    </div>
    """
  end

  attr :actor, Battler.Actor, required: true

  def actor_portrait_preview(assigns) do
    ~H"""
    <img
      draggable="false"
      src={~p"/images/actors/#{@actor.icon}"}
      class={[
        "size-10 self-center rounded-lg border-2",
        @actor.party == :allies && "border-emerald-500",
        @actor.party == :enemies && "border-rose-500"
      ]}
    />
    """
  end

  attr :ref, :any, required: true

  def countdown(assigns) do
    assigns = assign_new(assigns, :start, &Process.read_timer(&1.ref))

    assigns =
      assign_props(assigns, fn %{start: start} ->
        %{target: "> span", start: start}
      end)

    ~H"""
    <div
      id="turn-countdown"
      phx-hook="Timer"
      data-props={@props}
      phx-update="ignore"
      class={[
        "flex items-center gap-1 rounded bg-gray-950 px-2 py-0.5 tabular-nums text-gray-400",
        "data-[warning]:bg-red-950 data-[warning]:text-red-400"
      ]}
    >
      <UI.Media.icon name="timer" size={16} />
      <span data-start={@start}>...</span>
    </div>
    """
  end
end
