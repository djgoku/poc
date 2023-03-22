defmodule Poc.HomeVisitService.VisitTest do
  use Poc.DataCase

  import Poc.HomeVisitService.UserFixtures, only: [user_fixture: 0]

  alias Poc.HomeVisitService.Visit

  test "create" do
    changeset = Visit |> Ash.Changeset.for_create(:create, %{})
    refute changeset.valid?

    changeset =
      Visit |> Ash.Changeset.for_create(:create, %{task: "call to wish happy birthday!"})

    refute changeset.valid?

    changeset =
      Visit
      |> Ash.Changeset.for_create(:create, %{task: "call to wish happy birthday!", minutes: 50})

    assert changeset.valid?

    visit =
      Visit
      |> Ash.Changeset.for_create(:create, %{task: "call to wish happy birthday!", minutes: 50})
      |> Poc.HomeVisitService.create!()

    assert visit.task == "call to wish happy birthday!"
    assert visit.minutes == 50

    user_1 = user_fixture()

    user_2 = user_fixture()

    visit2 =
      Visit
      |> Ash.Changeset.for_create(:create, %{
        task: "call to wish happy birthday!",
        minutes: 50,
        member_id: user_1.id,
        pal_id: user_2.id
      })
      |> Poc.HomeVisitService.create!()

    assert visit2.member_id == user_1.id
    assert visit2.pal_id == user_2.id

    assert %Visit{} =
             visit =
             visit
             |> Ash.Changeset.for_update(:update, %{member_id: user_1.id, pal_id: user_2.id})
             |> Poc.HomeVisitService.update!()

    assert visit.member_id == user_1.id
    assert visit.pal_id == user_2.id
  end
end
