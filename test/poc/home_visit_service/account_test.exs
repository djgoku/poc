defmodule Poc.HomeVisitService.AccountTest do
  use Poc.DataCase

  import Poc.HomeVisitService.UserFixtures, only: [user_fixture: 0]

  alias Poc.HomeVisitService.Account
  alias Poc.HomeVisitService.Visit

  test "create" do
    changeset = Account |> Ash.Changeset.for_create(:create, %{})
    refute changeset.valid?

    changeset = Account |> Ash.Changeset.for_create(:create, %{type: :debit, minutes: 50})

    assert changeset.valid?

    user_1 = user_fixture()
    user_2 = user_fixture()

    visit =
      Visit
      |> Ash.Changeset.for_create(:create, %{
        task: "todo",
        minutes: 50,
        member_id: user_1.id,
        pal_id: user_2.id
      })
      |> Poc.HomeVisitService.create!()

    account_credit =
      Account
      |> Ash.Changeset.for_create(:create, %{
        type: :credit,
        minutes: 50,
        user_id: user_1.id,
        visit_id: visit.id
      })
      |> Poc.HomeVisitService.create!()

    assert account_credit.visit_id == visit.id
    assert account_credit.user_id == user_1.id
    assert account_credit.minutes == 50
    assert account_credit.type == :credit

    account_debit =
      Account
      |> Ash.Changeset.for_create(:create, %{
        type: :debit,
        minutes: 50,
        user_id: user_1.id,
        visit_id: visit.id
      })
      |> Poc.HomeVisitService.create!()

    assert account_debit.visit_id == visit.id
    assert account_debit.user_id == user_1.id
    assert account_debit.minutes == 50
    assert account_debit.type == :debit
  end
end
