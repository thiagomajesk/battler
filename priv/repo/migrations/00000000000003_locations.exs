defmodule Battler.Repo.Migrations.Locations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string, null: false
      add :biome, :string, null: false
      add :skull, :string, null: false
      add :danger, :integer, null: false, default: 1
      add :faction, :integer, null: true

      add :gold_cost, :integer, null: false, default: 1
      add :stamina_cost, :integer, null: false, default: 0
      add :mana_cost, :integer, null: false, default: 1

      add :gathering_boost, :float, null: false, default: 0.0
      add :farming_boost, :float, null: false, default: 0.0
      add :crafting_boost, :float, null: false, default: 0.0
      add :experience_boost, :float, null: false, default: 0.0
    end

    create unique_index(:locations, :name)
  end
end
