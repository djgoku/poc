defmodule Poc.HomeVisitService.UserFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poc.HomeVisitService.User` resource.
  """

  alias Poc.HomeVisitService.User

  @doc """
  Generate a user.
  """
  def user_fixture() do
    User
    |> Ash.Changeset.for_create(:create, %{
      email: unique_user_email(),
      first_name: "some first_name",
      last_name: "some last_name"
    })
    |> Poc.HomeVisitService.create!()
  end

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
end
