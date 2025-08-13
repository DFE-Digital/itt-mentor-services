scope module: :claims, as: :claims, constraints: {
  host: [ENV["CLAIMS_HOST"], *ENV.fetch("CLAIMS_HOSTS", "").split(",")],
} do
  root to: "pages#start"

  scope module: :pages do
    get :accessibility
    get :cookies
    get :terms
    get :privacy
    get :grant_conditions, path: "grant-conditions"
  end

  resources :service_updates, path: "service-updates", only: %i[index show]

  namespace :payments do
    resources :claims, only: %i[index] do
      get :download, on: :collection
    end
  end

  namespace :sampling do
    resources :claims, only: %i[index] do
      get :download, on: :collection
    end
  end

  namespace :clawback do
    resources :claims, only: %i[index] do
      get :download, on: :collection
    end
  end

  resources :schools, only: %i[index show] do
    scope module: :schools do
      resources :claims, except: %i[new create edit] do
        collection do
          get "new", to: "claims/add_claim#new", as: :new_add_claim
          get "new/:state_key/:step", to: "claims/add_claim#edit", as: :add_claim
          put "new/:state_key/:step", to: "claims/add_claim#update"
          get :rejected
        end

        resource :mentors, only: %i[new create edit update], module: :claims do
          member do
            get :create_revision
          end
        end

        resources :mentor_trainings, only: %i[edit update], module: :claims do
          member do
            get :create_revision
          end
        end

        member do
          get :remove
          get :confirmation

          get "edit", to: "claims/edit_claim#new", as: :new_edit_claim
          get "edit/:state_key/:step", to: "claims/edit_claim#edit", as: :edit_claim
          put "edit/:state_key/:step", to: "claims/edit_claim#update"

          get "invalid_provider", to: "claims/invalid_provider#new", as: :new_invalid_provider
          get "invalid_provider/:state_key/:step", to: "claims/invalid_provider#edit", as: :invalid_provider
          put "invalid_provider/:state_key/:step", to: "claims/invalid_provider#update"
        end

        collection do
          get :rejected
        end
      end

      resource :grant_conditions, only: %i[show update]

      resources :mentors, only: %i[index show destroy] do
        member { get :remove }

        collection do
          get "new", to: "mentors/add_mentor#new", as: :new_add_mentor
          get "new/:state_key/:step", to: "mentors/add_mentor#edit", as: :add_mentor
          put "new/:state_key/:step", to: "mentors/add_mentor#update"
        end
      end

      resources :users, only: %i[index show destroy] do
        get :remove, on: :member

        collection do
          get "new", to: "users/add_user#new", as: :new_add_user
          get "new/:state_key/:step", to: "users/add_user#edit", as: :add_user
          put "new/:state_key/:step", to: "users/add_user#update"
        end
      end
    end
  end

  namespace :support do
    root to: redirect("/support/schools")

    unless HostingEnvironment.env.production?
      resource :database, only: %i[destroy] do
        namespace :databases do
          resources :claims, only: [] do
            collection do
              get :revert_to_submitted
              put :update_to_submitted
            end
          end
        end
        get :reset
      end
    end

    namespace :claims do
      namespace :payments do
        resources :claims, only: %i[show] do
          member do
            get :confirm_information_sent, path: "information-sent"
            put :information_sent, path: "information-sent"

            get :confirm_paid, path: "paid"
            put :paid, path: "paid"

            get :confirm_reject, path: "reject"
            put :reject, path: "reject"
          end
        end
      end

      resources :payments, only: %i[index new create] do
        collection do
          get "payer_response/new", to: "payments/upload_payer_response#new", as: :new_upload_payer_response
          get "payer_response/new/:state_key/:step", to: "payments/upload_payer_response#edit", as: :upload_payer_response
          put "payer_response/new/:state_key/:step", to: "payments/upload_payer_response#update"
        end
      end
      resources :payment_responses, only: %i[new update] do
        post :check, on: :collection
      end

      resources :samplings, path: "sampling/claims", only: %i[index show] do
        member do
          get :confirm_approval
          put :update

          get "provider_rejected/new", to: "samplings/provider_rejected#new", as: :new_provider_rejected
          get "provider_rejected/new/:state_key/:step", to: "samplings/provider_rejected#edit", as: :provider_rejected
          put "provider_rejected/new/:state_key/:step", to: "samplings/provider_rejected#update"

          get "reject/new", to: "samplings/reject#new", as: :new_rejected
          get "reject/new/:state_key/:step", to: "samplings/reject#edit", as: :reject
          put "reject/new/:state_key/:step", to: "samplings/reject#update"
        end

        collection do
          get "new", to: "samplings/upload_data#new", as: :new_upload_data
          get "new/:state_key/:step", to: "samplings/upload_data#edit", as: :upload_data
          put "new/:state_key/:step", to: "samplings/upload_data#update"

          get "provider_response/new", to: "samplings/upload_provider_response#new", as: :new_upload_provider_response
          get "provider_response/new/:state_key/:step", to: "samplings/upload_provider_response#edit", as: :upload_provider_response
          put "provider_response/new/:state_key/:step", to: "samplings/upload_provider_response#update"
        end
      end

      resources :clawbacks, path: "clawbacks/claims", only: %i[index show new create] do
        member do
          get "edit/:claim_id/:mentor_training_id", to: "edit_request_clawback#new", as: :new_edit_request_clawback
          get "edit/:state_key/:claim_id/:mentor_training_id/:step", to: "edit_request_clawback#edit", as: :edit_request_clawback
          put "edit/:state_key/:claim_id/:mentor_training_id/:step", to: "edit_request_clawback#update"

          get "approval/:claim_id", to: "clawbacks/clawback_support_approval#new", as: :new_clawback_support_approval
          get "approval/:state_key/:claim_id/:step", to: "clawbacks/clawback_support_approval#edit", as: :clawback_support_approval
          put "approval/:state_key/:claim_id/:step", to: "clawbacks/clawback_support_approval#update"
        end

        collection do
          get "new/:claim_id", to: "request_clawback#new", as: :new_request_clawback
          get "new/:state_key/:claim_id/:step", to: "request_clawback#edit", as: :request_clawback
          put "new/:state_key/:claim_id/:step", to: "request_clawback#update"

          get "upload_esfa_response/new", to: "clawbacks/upload_esfa_response#new", as: :new_upload_esfa_response
          get "upload_esfa_response/new/:state_key/:step", to: "clawbacks/upload_esfa_response#edit", as: :upload_esfa_response
          put "upload_esfa_response/new/:state_key/:step", to: "clawbacks/upload_esfa_response#update"
        end
      end

      resources :claim_activities, path: "activity", only: %i[index show] do
        member do
          get :resend_payer_email
          get :resend_provider_email
        end
      end
    end

    resources :claims, only: %i[index show] do
      get :download_csv, on: :collection

      member do
        get "support_details/new", to: "claims/support_details#new", as: :new_support_details
        get "support_details/new/:state_key/:step", to: "claims/support_details#edit", as: :support_details
        put "support_details/new/:state_key/:step", to: "claims/support_details#update"
      end
    end

    resources :support_users, path: "support-users", only: %i[index show destroy] do
      get :remove, on: :member

      collection do
        get "new", to: "support_users/add_support_user#new", as: :new_add_support_user
        get "new/:state_key/:step", to: "support_users/add_support_user#edit", as: :add_support_user
        put "new/:state_key/:step", to: "support_users/add_support_user#update"
      end
    end

    resources :organisations do
      collection do
        get "new", to: "organisations/add_organisation#new", as: :new_add_organisation
        get "new/:state_key/:step", to: "organisations/add_organisation#edit", as: :add_organisation
        put "new/:state_key/:step", to: "organisations/add_organisation#update"
      end
    end

    resources :providers, only: [] do
      collection do
        get :search
      end
    end

    resources :mentors, only: [] do
      collection do
        get "search/:academic_year_id", to: "mentors#search", as: :search
      end
    end

    resources :schools, only: %i[index show] do
      collection do
        get :search
      end

      member do
        put :remove_grant_conditions_acceptance, path: "remove-grant-conditions-acceptance"
        get :remove_grant_conditions_acceptance_check, path: "remove-grant-conditions-acceptance"
      end

      collection do
        get "new", to: "schools/add_school#new", as: :new_add_school
        get "new/:state_key/:step", to: "schools/add_school#edit", as: :add_school
        put "new/:state_key/:step", to: "schools/add_school#update"

        get "onboard", to: "settings/onboard_schools#new", as: :new_onboard_schools
        get "onboard/:state_key/:step", to: "settings/onboard_schools#edit", as: :onboard_schools
        put "onboard/:state_key/:step", to: "settings/onboard_schools#update"

        get "onboard_users", to: "settings/onboard_users#new", as: :new_onboard_users
        get "onboard_users/:state_key/:step", to: "settings/onboard_users#edit", as: :onboard_users
        put "onboard_users/:state_key/:step", to: "settings/onboard_users#update"
      end
    end

    get :settings, to: "settings#index"

    resources :mailers, only: :index

    resources :manually_onboarded_schools, only: :index

    resources :claims_reminders do
      collection do
        get "schools_not_submitted_claims", to: "claims_reminders#schools_not_submitted_claims", as: :schools_not_submitted_claims
        post "schools_not_submitted_claims", to: "claims_reminders#send_schools_not_submitted_claims", as: :send_schools_not_submitted_claims

        get "providers_not_submitted_claims", to: "claims_reminders#providers_not_submitted_claims", as: :providers_not_submitted_claims
        post "providers_not_submitted_claims", to: "claims_reminders#send_providers_not_submitted_claims", as: :send_providers_not_submitted_claims
      end
    end

    get "export_users", to: "settings/export_users#new", as: :new_claims_export_users
    get "export_users/:state_key/:step", to: "settings/export_users#edit", as: :claims_export_users
    put "export_users/:state_key/:step", to: "settings/export_users#update"
    post "export_users/:state_key/download", to: "settings/export_users#download", as: :download_claims_export_users
    resources :claim_windows do
      get :new_check, path: :check, on: :collection
      get :edit_check, path: :check, on: :member
      get :remove, on: :member
    end
  end
end
