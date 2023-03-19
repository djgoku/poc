defmodule Poc.HomeVisitService.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("users")
    repo(Poc.Repo)
  end

  actions do
    defaults([:create, :read, :update, :destroy])
  end

  attributes do
    uuid_primary_key(:id)

    attribute :first_name, :string do
      allow_nil?(false)
    end

    attribute :last_name, :string do
      allow_nil?(false)
    end

    attribute :email, :string do
      allow_nil?(false)
    end
  end

  identities do
    identity(:email, [:email])
  end
end
