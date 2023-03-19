defmodule Poc.HomeVisitService.UserTest do
  use Poc.DataCase

  alias Poc.HomeVisitService.User

  @valid_params %{
    first_name: "johnny",
    last_name: "five",
    email: "johnny-five@example.com"
  }

  test "create" do
    changeset = User |> Ash.Changeset.for_create(:create, %{})
    refute changeset.valid?

    changeset = User |> Ash.Changeset.for_create(:create, %{first_name: "johnny"})
    refute changeset.valid?

    changeset =
      User |> Ash.Changeset.for_create(:create, %{first_name: "johnny", last_name: "five"})

    refute changeset.valid?

    changeset =
      User
      |> Ash.Changeset.for_create(:create, @valid_params)

    assert changeset.valid?

    assert user =
             %User{} =
             User
             |> Ash.Changeset.for_create(:create, @valid_params)
             |> Poc.HomeVisitService.create!()

    assert user.first_name == "johnny"
    assert user.last_name == "five"
    assert user.email == "johnny-five@example.com"

    assert {:error, %Ash.Error.Invalid{} = error} =
             User
             |> Ash.Changeset.for_create(:create, @valid_params)
             |> Poc.HomeVisitService.create()

    assert %Ash.Error.Changes.InvalidAttribute{field: :email, message: "has already been taken"} =
             error.errors |> List.first()
  end
end
