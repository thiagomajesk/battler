defmodule Battler.Actor do
  defstruct [
    :id,
    :name,
    :icon,
    :hp,
    :max_hp,
    :mp,
    :max_mp,
    :cp,
    :max_cp,
    :atk,
    :def,
    :mat,
    :luk,
    :mdf,
    :spd,
    :party,
    ai?: false,
    skills: []
  ]

  alias __MODULE__

  def ready?(%Actor{cp: cp, max_cp: max_cp}), do: cp >= max_cp
  def tired?(%Actor{cp: cp}), do: cp <= 0
  def dead?(%Actor{hp: hp}), do: hp <= 0
  def self?(%Actor{id: id1}, %Actor{id: id2}), do: id1 == id2
  def allies?(%Actor{party: p1}, %Actor{party: p2}), do: p1 == p2
  def enemies?(%Actor{party: p1}, %Actor{party: p2}), do: p1 != p2

  def recover_charge(%Actor{} = actor) do
    increase = Enum.random(1..actor.spd)
    Map.update!(actor, :cp, &min(&1 + increase, actor.max_cp))
  end
end
