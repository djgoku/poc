defmodule Poc.Repo do
  use AshPostgres.Repo, otp_app: :poc

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
