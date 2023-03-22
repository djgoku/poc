defmodule Poc.HomeVisitService.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("accounts")
    repo(Poc.Repo)
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :credits do
      filter(expr(type == :credit))
    end

    read :debits do
      filter(expr(type == :debit))
    end
  end

  attributes do
    uuid_primary_key(:id)

    attribute :type, :atom do
      constraints(one_of: [:credit, :debit])
      allow_nil?(false)
    end

    attribute :minutes, :integer do
      allow_nil?(false)
    end
  end

  relationships do
    belongs_to :user, Poc.HomeVisitService.User do
      attribute_writable?(true)
    end

    belongs_to :visit, Poc.HomeVisitService.Visit do
      attribute_writable?(true)
    end
  end
end
