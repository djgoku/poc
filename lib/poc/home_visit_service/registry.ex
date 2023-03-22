defmodule Poc.HomeVisitService.Registry do
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry(Poc.HomeVisitService.Account)
    entry(Poc.HomeVisitService.User)
    entry(Poc.HomeVisitService.Visit)
  end
end
