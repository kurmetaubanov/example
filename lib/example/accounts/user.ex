defmodule Example.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication, AshGraphql.Resource]

  actions do
    # Add a set of simple actions. You'll customize these later.
    defaults [:create, :read, :update, :destroy]

    create :register do
      argument :password, :string, allow_nil?: false, sensitive?: true
      argument :password_confirmation, :string, allow_nil?: false, sensitive?: true
      validate confirm(:password, :password_confirmation)

      change set_context(%{strategy_name: :password})
      change AshAuthentication.Strategy.Password.HashPasswordChange
      change AshAuthentication.GenerateTokenChange

    end

  end

  postgres do
    table "users"
    repo Example.Repo
  end

  attributes do
    attribute :id, :string, primary_key?: true, allow_nil?: false, default: fn -> Example.Utils.Ksuid.generate("user") end
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: true, sensitive?: true
    attribute :created_at, :datetime, default: &DateTime.utc_now/0
    attribute :updated_at, :datetime, default: &DateTime.utc_now/0, writable?: false
  end

  validations do
    validate match(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/) do
      message "invalid email format"
    end
  end

  identities do
    identity :unique_email, [:email]
  end

  authentication do
    api Example.Accounts

    strategies do
      password :password do
        identity_field :email
        hashed_password_field :hashed_password
        sign_in_tokens_enabled? true
        # resettable do
        #   sender Example.Accounts.User.Senders.SendPasswordResetEmail
        # end
      end
    end

    tokens do
      enabled? true
      token_resource Example.Accounts.Token

      signing_secret Example.Accounts.Secrets
    end
  end

  graphql do
    type :user

    queries do
      get :get_user, :read
      list :list_users, :read

      # following sign_in_with_password declaration will require query of following format and return token
      # mutation {
      #   signInWithPassword(email: "kurmet@gmail.com", password: "12345678") {
      #     id
      #     email
      #     token
      #   }
      # }
      read_one :sign_in_with_password, :sign_in_with_password do
        as_mutation? true
        type_name :user_with_token
      end

    end

    mutations do

      # following register declaration will require query of following format
      # mutation {
      #   registerWithPassword(
      #     input: {
      #       email: "yo@gmail.com",
      #       password: "123456",
      #       passwordConfirmation: "123456"
      #     }
      #   ) {
      #     result {
      #       id
      #     }
      #   }
      # }
      create :register_with_password, :register

    end
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end

end
