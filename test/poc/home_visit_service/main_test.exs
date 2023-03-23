defmodule Poc.HomeVisitService.MainTest do
  use Poc.DataCase
  doctest Poc.HomeVisitService.Main

  import Ash.Query
  import Poc.HomeVisitService.UserFixtures, only: [user_fixture: 0]
  alias Poc.HomeVisitService.Account
  alias Poc.HomeVisitService.Main
  alias Poc.HomeVisitService.User
  alias Poc.HomeVisitService.Visit

  setup do
    %{user_1: user_fixture(), user_2: user_fixture()}
  end

  test "calculate_overhead/3" do
    assert Main.calculate_overhead(100) == 85
    assert Main.calculate_overhead(100, 0.10) == 90
  end

  test "create_user/1" do
    assert %User{} =
             Main.create_user(%{email: "test@example.com", first_name: "Test", last_name: "User"})
  end

  test "request_visit/4", %{user_1: member, user_2: pal} do
    assert Main.request_visit(member, pal, 10, "Chat about things") ==
             {:error, :visit_not_possible}

    assert Main.user_balance(member) == 0
    Main.add_starting_balance(member, 10)
    assert Main.user_balance(member) == 10

    assert {:ok, _account} = Main.request_visit(member, pal, 10, "Chat about things")

    assert Main.user_balance(member) == 0
    assert Main.user_balance(pal) == 8

    member_account_after_visit =
      Account
      |> Ash.Query.filter(not is_nil(visit_id))
      |> Ash.Query.filter(user_id == ^member.id)
      |> Poc.HomeVisitService.read_one!()

    assert member_account_after_visit.minutes == 10
    assert member_account_after_visit.type == :credit

    pal_account_after_visit =
      Account
      |> Ash.Query.filter(not is_nil(visit_id))
      |> Ash.Query.filter(user_id == ^pal.id)
      |> Poc.HomeVisitService.read_one!()

    assert pal_account_after_visit.minutes == 8
    assert pal_account_after_visit.type == :debit

    visit =
      Visit
      |> Ash.Query.filter(id == ^pal_account_after_visit.visit_id)
      |> Poc.HomeVisitService.read_one!()

    assert visit.member_id == member.id
    assert visit.pal_id == pal.id
    assert visit.task == "Chat about things"
  end
end
