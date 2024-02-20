defmodule Example.Accounts do
  use Ash.Api, extensions: [
    AshGraphql.Api
  ]

  graphql do
    authorize? true # Defaults to `true`, use this to disable authorization for the entire API (you probably only want this while prototyping)
    show_raised_errors? true
    root_level_errors? true
  end

  resources do
    resource Example.Accounts.User
    resource Example.Accounts.Token
  end
end
