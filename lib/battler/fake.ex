defmodule Battler.Fake do
  alias Battler.Actor
  alias Battler.Skill

  def list_allies() do
    [
      %Actor{
        id: "e2858441-e88d-4495-b146-850bca7c75e9",
        name: "Eric",
        icon: "eric-warrior.png",
        hp: 100,
        max_hp: 200,
        mp: 100,
        max_mp: 100,
        cp: 0,
        max_cp: 100,
        def: 10,
        mdf: 50,
        atk: 10,
        mat: 20,
        luk: 10,
        spd: 50,
        party: :allies,
        skills: [
          %Skill{
            id: "a7b2a161-7929-4572-ad88-7547960788e2",
            name: "Increase Protection",
            description: "The Increase Protection Skill",
            icon: "black-hand-shield.svg",
            target: :party,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "3cd1ad96-c4c7-471f-8d4b-96e797bb94cb",
            name: "Slash Strike",
            description: "The Slash Strike Skill",
            icon: "sword-wound.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "fc817786-299e-42ce-b250-162bc60b011b",
            name: "Power Strike",
            description: "The Power Strike Skill",
            icon: "wide-arrow-dunk.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "11629ba6-0806-4bba-a67f-0479a7667a7e",
            name: "Ubiquitus Defence",
            description: "The Ubiquitus Defence Skill",
            icon: "shield-reflect.svg",
            target: :self,
            cp_cost: 100,
            mp_cost: 10
          }
        ]
      },
      %Actor{
        id: "540a2a02-843d-4ff1-b721-98d8c3cae410",
        name: "Lucy",
        icon: "lucy-cleric.png",
        hp: 100,
        max_hp: 200,
        mp: 100,
        max_mp: 100,
        cp: 0,
        max_cp: 100,
        def: 10,
        mdf: 50,
        atk: 10,
        mat: 20,
        luk: 10,
        spd: 100,
        party: :allies,
        skills: [
          %Skill{
            id: "021ffe25-632b-4ff1-92e8-36450827b698",
            name: "Minor Healing",
            description: "Heals itself for 20% of your total health",
            icon: "healing.svg",
            target: :self,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "a8339280-4e0f-4355-8f82-5a9f2e388f80",
            name: "Great Impact",
            description: "The Great Impact Skill",
            icon: "screen-impact.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "40b9dfa3-ec3d-4f49-90ac-dba9126a3cd3",
            name: "Decrease Defences",
            description: "The Decrease Defences Skill",
            icon: "team-downgrade.svg",
            target: :enemies,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "edd31e92-3db9-4079-9974-86ab5cddf5d1",
            name: "Increase Defences",
            description: "Increase Defences Skill",
            icon: "team-upgrade.svg",
            target: :allies,
            cp_cost: 100,
            mp_cost: 10
          }
        ]
      },
      %Actor{
        id: "556709a2-a47f-43a8-b96c-e48d86035e72",
        name: "Adam",
        icon: "adam-mage.png",
        hp: 100,
        max_hp: 200,
        mp: 100,
        max_mp: 100,
        cp: 0,
        max_cp: 100,
        def: 10,
        mdf: 50,
        atk: 10,
        mat: 20,
        luk: 10,
        spd: 50,
        party: :allies,
        skills: [
          %Skill{
            id: "cc2607ff-090d-4f4c-9965-9ca0eb1cab4f",
            name: "Poison Cloud",
            description: "The Poison Cloud Skill",
            icon: "foamy-disc.svg",
            target: :enemies,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "53a2ce5d-24c0-40e4-bd2c-e0653cfdbabe",
            name: "Fireball",
            description: "The Fireball Skill",
            icon: "fireball.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "7b9bb8ae-748f-4611-893f-54c6b3428759",
            name: "Strangle",
            description: "The Strangle Skill",
            icon: "heavy-thorny-triskelion.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "e1d86540-deb1-4ab3-b667-c8c0ec025293",
            name: "Ice Spear",
            description: "The Ice Spear Skill",
            icon: "ice-spear.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          }
        ]
      },
      %Actor{
        id: "715788ea-ec4b-4242-a852-e96ce745f00f",
        name: "Edgar",
        icon: "edgar-paladin.png",
        hp: 100,
        max_hp: 200,
        mp: 100,
        max_mp: 100,
        cp: 0,
        max_cp: 100,
        def: 10,
        mdf: 50,
        atk: 10,
        mat: 20,
        luk: 10,
        spd: 50,
        party: :allies,
        skills: [
          %Skill{
            id: "81b180a4-7c6c-43e5-80df-5ba23db9aa64",
            name: "Poison Cloud",
            description: "The Poison Cloud Skill",
            icon: "foamy-disc.svg",
            target: :enemies,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "a3c08b6d-2adc-4966-bea1-6592b8bdff3a",
            name: "Fireball",
            description: "The Fireball Skill",
            icon: "fireball.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "71097d2b-eab1-457d-af0e-f1b545cf924b",
            name: "Strangle",
            description: "The Strangle Skill",
            icon: "heavy-thorny-triskelion.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          },
          %Skill{
            id: "4e272b44-42a2-469c-b3db-5dcbf6d6ef21",
            name: "Ice Spear",
            description: "The Ice Spear Skill",
            icon: "ice-spear.svg",
            target: :enemy,
            cp_cost: 100,
            mp_cost: 10
          }
        ]
      }
    ]
  end

  def list_enemies() do
    [
      %Actor{
        id: "b90c6591-7b12-4e4a-8927-672c4e6d595a",
        name: "Goblin",
        icon: "goblin.png",
        hp: 100,
        max_hp: 200,
        mp: 100,
        max_mp: 100,
        cp: 0,
        max_cp: 100,
        def: 10,
        mdf: 50,
        atk: 10,
        mat: 20,
        luk: 10,
        spd: 50,
        party: :enemies,
        ai?: true
      },
      %Actor{
        id: "330ba00a-7cc5-483a-a42e-bc27e68ecdca",
        name: "Shadow",
        icon: "shadow.png",
        hp: 200,
        max_hp: 200,
        mp: 100,
        max_mp: 100,
        cp: 0,
        max_cp: 100,
        def: 10,
        mdf: 50,
        atk: 10,
        mat: 20,
        luk: 10,
        spd: 50,
        party: :enemies,
        ai?: true
      },
      %Actor{
        id: "2e30759c-3927-424d-8025-4eb589238f7e",
        name: "Skeleton",
        icon: "skeleton.png",
        hp: 200,
        max_hp: 200,
        mp: 100,
        max_mp: 100,
        cp: 0,
        max_cp: 100,
        def: 10,
        mdf: 50,
        atk: 10,
        mat: 20,
        luk: 10,
        spd: 50,
        party: :enemies,
        ai?: true
      },
      %Actor{
        id: "4ca9d088-e67f-43d6-b2c2-9a877703a406",
        name: "Ooze",
        icon: "ooze.png",
        hp: 200,
        max_hp: 200,
        mp: 100,
        max_mp: 100,
        cp: 0,
        max_cp: 100,
        def: 10,
        mdf: 50,
        atk: 10,
        mat: 20,
        luk: 10,
        spd: 50,
        party: :enemies,
        ai?: true
      }
    ]
  end
end
