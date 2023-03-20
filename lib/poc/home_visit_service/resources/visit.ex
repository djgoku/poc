defmodule Poc.HomeVisitService.Visit do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("visits")
    repo(Poc.Repo)
  end

  actions do
    defaults([:create, :read, :update, :destroy])
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:task, :string) do
      allow_nil?(false)
    end

    attribute(:minutes, :integer) do
      allow_nil?(false)
    end
  end

  relationships do
    belongs_to(:member, Poc.HomeVisitService.User) do
      attribute_writable?(true)
    end

    belongs_to(:pal, Poc.HomeVisitService.User) do
      attribute_writable?(true)
    end
  end
end
