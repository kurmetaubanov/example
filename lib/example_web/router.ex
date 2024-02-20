defmodule ExampleWeb.Router do
  use ExampleWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExampleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug AshGraphql.Plug
  end

  pipeline :api_restrict do
    plug :user_authorized
  end

  scope "/", ExampleWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api/v1" do
    pipe_through [:api]

    forward "/gql", Absinthe.Plug, schema: Example.Schema
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:example, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ExampleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # tiny plug to process load_from_bearer's plug result
  defp user_authorized(conn, _opts) do
    if Map.get(conn.assigns, :current_user, false) do
      conn
    else
      conn
      |> put_status(401) # Unauthorized
      |> put_resp_header("content-type", "application/json")
      |> send_resp(401, "Unauthorized")
      |> halt()
    end
  end
end
