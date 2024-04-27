defmodule Battler.Combat do
  alias Battler.Skill

  def apply_skill_effects(%Skill{} = _skill, targets) do
    Enum.map(targets, fn target ->
      # Gives a random amount of damage to the targets
      # TODO: Process the actual skill effect in here
      damage = Enum.random(10..100)
      %{target | hp: max(target.hp - damage, 0)}
    end)
  end
end
