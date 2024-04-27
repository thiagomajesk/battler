defmodule Battler.Skill do
  defstruct [
    :id,
    :name,
    :description,
    :icon,
    :target,
    :cp_cost,
    :mp_cost,
    cooldown: 0,
    aspects: []
  ]

  def add_enemy_damage_effect(skill, min, max) do
    Map.update!(skill, :effects, fn effects ->
      [{:damage, :enemy, min, max} | effects]
    end)
  end
end
