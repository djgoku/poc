defmodule Poc.HomeVisitService.VisitFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poc.HomeVisitService.Visit` resource.
  """

  alias Poc.HomeVisitService.Visit

  @doc """
  Generate a visit.
  """
  def visit_fixture(member, pal, task \\ "Help member", minutes \\ 60) do
    Visit
    |> Ash.Changeset.for_create(:create, %{
      task: task,
      minutes: minutes,
      member_id: member.id,
      pal_id: pal.id
    })
    |> Poc.HomeVisitService.create!()
  end
end
