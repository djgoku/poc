defmodule Poc.HomeVisitService.VisitTest do
  use Poc.DataCase

  alias Poc.HomeVisitService.User
  alias Poc.HomeVisitService.Visit

  @valid_user_params_1 %{
    first_name: "johnny",
    last_name: "five",
    email: "johnny-five@example.com"
  }

  @valid_user_params_2 %{
    first_name: "five",
    last_name: "johnny",
    email: "five-johnny@example.com"
  }

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

    user_1 =
      User
      |> Ash.Changeset.for_create(:create, @valid_user_params_1)
      |> Poc.HomeVisitService.create!()

    user_2 =
      User
      |> Ash.Changeset.for_create(:create, @valid_user_params_2)
      |> Poc.HomeVisitService.create!()

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
             # |> Ash.Changeset.manage_relationship(:member, [user_1], on_lookup: :relate)
             # |> Ash.Changeset.manage_relationship(:pal, [user_2], on_lookup: :relate)
             |> Poc.HomeVisitService.update!()

    assert visit.member_id == user_1.id
    assert visit.pal_id == user_2.id
  end
end
