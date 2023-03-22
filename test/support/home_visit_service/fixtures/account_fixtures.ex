defmodule Poc.HomeVisitService.AccountFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poc.HomeVisitService.Account` resource.
  """

  alias Poc.HomeVisitService.Account

  @doc """
  Generate a account.
  """
  def account_fixture(user, visit, type \\ :debit, minutes \\ 60) do
    Account
    |> Ash.Changeset.for_create(:create, %{
      type: type,
      minutes: minutes,
      user_id: user.id,
      visit_id: visit.id
    })
    |> Poc.HomeVisitService.create!()
  end
end
