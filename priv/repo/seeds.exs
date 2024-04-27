# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Battler.Repo.insert!(%Battler.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Battler.Repo.insert!(%Battler.Engine.Spell{
#   name: "Time Steal",
#   code: "TIME_STEAL",
#   type: :active,
#   element: :water,
#   scope: :enemy,
#   base_effects: [
#     %{
#       type: :steal,
#       value: 1,
#       duration: 1
#     },
#     %{
#       type: :damage,
#       element: :water,
#       min: 491,
#       max: 537
#     }
#   ],
#   crit_effects: [
#     %{
#       type: :energy_steal,
#       value: 1,
#       duration: 1
#     },
#     %{
#       type: :damage,
#       element: :water,
#       min: 649,
#       max: 706
#     },
#     %{
#       type: :debuff,
#       stat: :energy,
#       decrease: 2
#     },
#     %{
#       type: :debuff,
#       stat: :fire_def,
#       decrease: 2
#     },
#     %{
#       type: :state,
#       state: :demotivation,
#       duration: 1
#     },
#     %{
#       type: :buff,
#       stat: :ciritcal,
#       increase: 0.20
#     }
#   ]
# })
