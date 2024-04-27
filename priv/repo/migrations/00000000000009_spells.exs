defmodule Battler.Repo.Migrations.Spells do
  use Ecto.Migration

  def change do
    create table(:spells) do
      add :name, :string, null: false
      add :code, :string, null: false
      add :type, :string, null: false
      add :element, :string, null: false
      add :scope, :string, null: false
      add :priority, :integer, default: 0
      add :cooldown, :integer, default: 0
      add :max_stack, :integer, default: 0

      add :base_effects, :map
      add :crit_effects, :map
    end

    create unique_index(:spells, :name)
    create unique_index(:spells, :code)
  end
end
