defmodule Poc.HomeVisitService.Registry do
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry(Poc.HomeVisitService.User)
  end
end