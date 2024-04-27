defmodule Battler.Repo.Migrations.Characters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string, null: false
      add :title, :string, null: true
      add :gender, :string, null: false
      add :faction, :string, null: false
      add :level, :integer, null: false, default: 1

      add :soul, :integer, null: false, default: 0
      add :soul_max, :integer, null: false, default: 0

      add :stamina, :integer, null: false, default: 0
      add :stamina_max, :integer, null: false, default: 0

      add :strength, :integer, null: false, default: 1
      add :dexterity, :integer, null: false, default: 1
      add :constitution, :integer, null: false, default: 1
      add :intelligence, :integer, null: false, default: 1

      add :owner_id, references(:users), null: false

      timestamps()
    end

    create unique_index(:characters, :name)
  end
end
