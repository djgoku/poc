defmodule Poc.HomeVisitService do
  use Ash.Api

  resources do
    registry(Poc.HomeVisitService.Registry)
  end
end
