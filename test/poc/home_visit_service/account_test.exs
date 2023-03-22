defmodule Poc.HomeVisitService.AccountTest do
  use Poc.DataCase

  import Poc.HomeVisitService.AccountFixtures, only: [account_fixture: 4]
  import Poc.HomeVisitService.UserFixtures, only: [user_fixture: 0]
  import Poc.HomeVisitService.VisitFixtures, only: [visit_fixture: 4]

  alias Poc.HomeVisitService.Account
  alias Poc.HomeVisitService.Visit

  test "create" do
    changeset = Account |> Ash.Changeset.for_create(:create, %{})
    refute changeset.valid?

    changeset = Account |> Ash.Changeset.for_create(:create, %{type: :debit, minutes: 50})

    assert changeset.valid?

    member = user_fixture()
    pal = user_fixture()

    visit = visit_fixture(member, pal, "todo", 50)

    account_credit = account_fixture(member, visit, :credit, 50)

    assert account_credit.visit_id == visit.id
    assert account_credit.user_id == member.id
    assert account_credit.minutes == 50
    assert account_credit.type == :credit

    account_debit = account_fixture(pal, visit, :debit, 50)

    assert account_debit.visit_id == visit.id
    assert account_debit.user_id == pal.id
    assert account_debit.minutes == 50
    assert account_debit.type == :debit
  end
end
