defmodule Poc.HomeVisitService.VisitTest do
  use Poc.DataCase

  import Poc.HomeVisitService.UserFixtures, only: [user_fixture: 0]
  import Poc.HomeVisitService.VisitFixtures, only: [visit_fixture: 4]

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

    member = user_fixture()
    pal = user_fixture()

    visit = visit_fixture(member, pal, "call to wish happy birthday!", 50)

    assert visit.task == "call to wish happy birthday!"
    assert visit.minutes == 50
    assert visit.member_id == member.id
    assert visit.pal_id == pal.id
  end
end
