defmodule Poc.HomeVisitService.Main do
  import Ash.Query
  alias Poc.HomeVisitService.Account
  alias Poc.HomeVisitService.User
  alias Poc.HomeVisitService.Visit

  @doc ~S"""
  Calculate overhead defaulting to `overhead_percentage` of 15% and defaulting `rounder` to `Kernel.round/1`

  ## Examples

      iex> Poc.HomeVisitService.Main.calculate_overhead(100)
      85
  """

  def calculate_overhead(minutes, overhead_percentage \\ 0.15, rounder \\ &Kernel.round/1) do
    minutes - rounder.(minutes * overhead_percentage)
  end

  @doc ~S"""
  Create a `Poc.HomeVisitService.User` resource.

  ## Examples

      iex> %Poc.HomeVisitService.User{} = Poc.HomeVisitService.Main.create_user(%{email: "johnny@example.com", first_name: "johnny", last_name: "five"})
  """
  def create_user(%{email: _email, first_name: _first_name, last_name: _last_name} = user_info) do
    User
    |> Ash.Changeset.for_create(:create, user_info)
    |> Poc.HomeVisitService.create!()
  end

  @doc ~S"""
  Create a `Poc.HomeVisitService.Visit` resource.

  ## Examples

      iex> member = Poc.HomeVisitService.Main.create_user(%{email: "member@example.com", first_name: "mem", last_name: "ber"})
      ...> pal = Poc.HomeVisitService.Main.create_user(%{email: "pal@example.com", first_name: "pa", last_name: "l"})
      ...> %Poc.HomeVisitService.Visit{} = Poc.HomeVisitService.Main.create_visit(member, pal, 10, "Chat about the week!")
  """
  def create_visit(member, pal, minutes, task) do
    Visit
    |> Ash.Changeset.for_create(:create, %{
      task: task,
      minutes: minutes,
      member_id: member.id,
      pal_id: pal.id
    })
    |> Poc.HomeVisitService.create!()
  end

  @doc ~S"""
  A member is requesting a visit.

  ## Examples

      iex> member = Poc.HomeVisitService.Main.create_user(%{email: "member@example.com", first_name: "mem", last_name: "ber"})
      ...> pal = Poc.HomeVisitService.Main.create_user(%{email: "pal@example.com", first_name: "pa", last_name: "l"})
      ...> {:error, :visit_not_possible} = Poc.HomeVisitService.Main.request_visit(member, pal, 10, "Chat about the week!")
  """
  def request_visit(member, pal, minutes, task) do
    if can_member_be_visited?(member, minutes) do
      pal_credit_minutes = calculate_overhead(minutes)

      Poc.Repo.transaction(fn ->
        visit = create_visit(member, pal, minutes, task)
        create_account_record(member, visit, :credit, minutes)
        create_account_record(pal, visit, :debit, pal_credit_minutes)
      end)
    else
      {:error, :visit_not_possible}
    end
  end

  def create_account_record(%User{} = user, %Visit{} = visit, type, minutes) do
    Account
    |> Ash.Changeset.for_create(:create, %{
      user_id: user.id,
      visit_id: visit.id,
      type: type,
      minutes: minutes
    })
    |> Poc.HomeVisitService.create!()
  end

  def add_starting_balance(%User{} = user, minutes) do
    Account
    |> Ash.Changeset.for_create(:create, %{
      user_id: user.id,
      type: :debit,
      minutes: minutes
    })
    |> Poc.HomeVisitService.create!()
  end

  def user_balance(user) do
    user_total(user, :debits) - user_total(user, :credits)
  end

  # if we don't have this case we would return true if a user had a 0
  # debits, 0 credits and we passed 0 minutes.
  defp can_member_be_visited?(_, 0), do: false

  defp can_member_be_visited?(%User{} = user, minutes) do
    case user_balance(user) - minutes do
      x when x >= 0 -> true
      _ -> false
    end
  end

  defp user_total(%User{} = user, type) do
    Account
    |> Ash.Query.filter(user_id == ^user.id)
    |> Ash.Query.for_read(type)
    |> Poc.HomeVisitService.sum!(:minutes) || 0
  end
end
