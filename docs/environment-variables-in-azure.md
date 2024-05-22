# Environment Variables in Azure

There are two ways to set environment variables in the Azure hosting environment. The process depends on whether the value is considered 'secret' or not.

Environment variables that contain passwords, API keys or encryption keys should be considered secret. Most other environment variables can be considered non-secret – for example, hostnames for external API integrations, or runtime configuration such as `RAILS_ENV`.

## Quick links

| Environment | 📝 Non-secret variables  | 🔒 Secret variables        |
| ----------- | ------------------------ | -------------------------- |
| Review apps | [review_app_env.yml]     | [s189t01-ittms-rv-app-kv]  |
| QA          | [qa_app_env.yml]         | [s189t01-ittms-qa-app-kv]  |
| Staging     | [staging_app_env.yml]    | [s189t01-ittms-stg-app-kv] |
| Sandbox     | [sandbox_app_env.yml]    | [s189p01-ittms-sb-app-kv]  |
| Production  | [production_app_env.yml] | [s189p01-ittms-pd-app-kv]  |

## Secret environment variables

Secret environment variables are stored in Azure Key Vault.

1. Login to the [Microsoft Azure portal](https://portal.azure.com)

   > Use your `@digitalauth.education.gov.uk` account.
   >
   > Make sure it says "DfE Platform Identity" in the top right corner of the screen below your name. If not, click the settings/cog icon and choose it from the list of directories.

2. Go to the [Key vaults](https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.KeyVault%2Fvaults) service and open the key vault that you need to edit.

   > Key vaults are named after the app and environment they belong to.
   >
   > | Environment | Key vault                  |                               |
   > | ----------- | -------------------------- | ----------------------------- |
   > | Review apps | [s189t01-ittms-rv-app-kv]  |                               |
   > | QA          | [s189t01-ittms-qa-app-kv]  |                               |
   > | Staging     | [s189t01-ittms-stg-app-kv] |                               |
   > | Sandbox     | [s189p01-ittms-sb-app-kv]  | ℹ️ Requires production access |
   > | Production  | [s189p01-ittms-pd-app-kv]  | ℹ️ Requires production access |

[s189t01-ittms-rv-app-kv]: https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/20da9d12-7ee1-42bb-b969-3fe9112964a7/resourceGroups/s189t01-ittms-rv-rg/providers/Microsoft.KeyVault/vaults/s189t01-ittms-rv-app-kv/secrets
[s189t01-ittms-qa-app-kv]: https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/20da9d12-7ee1-42bb-b969-3fe9112964a7/resourceGroups/s189t01-ittms-qa-rg/providers/Microsoft.KeyVault/vaults/s189t01-ittms-qa-app-kv/secrets
[s189t01-ittms-stg-app-kv]: https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/20da9d12-7ee1-42bb-b969-3fe9112964a7/resourceGroups/s189t01-ittms-stg-rg/providers/Microsoft.KeyVault/vaults/s189t01-ittms-stg-app-kv/secrets
[s189p01-ittms-sb-app-kv]: https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-ittms-sb-rg/providers/Microsoft.KeyVault/vaults/s189p01-ittms-sb-app-kv/secrets
[s189p01-ittms-pd-app-kv]: https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-ittms-pd-rg/providers/Microsoft.KeyVault/vaults/s189p01-ittms-pd-app-kv/secrets

3. **For sandbox and production environments**, you'll need to activate production permissions on your account.

   > 1. Go to [PIM > My roles > Groups](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/aadgroup)
   > 2. Click "Activate" on `s189 BAT production PIM`.
   > 3. Enter a reason for needing production access and click "Activate".
   > 4. All developers on your team will receive an email notification of your request. Ask someone to approve the request.
   > 5. After it's been granted, you'll need to wait a while (~15 minutes) for Key Vault to recognise your new permissions.

4. Click "Secrets" and you'll see a list of environment variables available to the app.

   > Secrets are named after the environment variables they represent.
   >
   > Underscores (`_`) are not allowed in secret names, so dashes (`-`) are used instead. These will be translated to underscores in the app's environment.
   >
   > For example, `SECRET-KEY-BASE` will become the environment variable `SECRET_KEY_BASE`.

### Add a new secret

From the key vault "Secrets" page:

1. Click "Generate/Import"
2. Set details for the environment variable:

   > **Name:** Name for the environment variable. Replace underscores (`_`) with dashes (`-`).  
   > **Secret value:** Value for the environment variable

3. Click "Create"

### Update an existing secret

From the key vault "Secrets" page:

1. Click on the secret you need to update
2. Click "New Version"
3. Enter the secret value and click "Create"

> [!NOTE]  
> You will need to [re-deploy the app](https://github.com/DFE-Digital/itt-mentor-services/actions/workflows/deploy.yml) for secret changes to be applied.

## Non-secret environment variables

Non-secret environment variables are kept directly in the code repository.

> [!CAUTION]
> This code repository is publicly visible. Do not store secrets here.

1. Go to the directory `terraform/application/config`
2. Update environment variables defined in the YAML configuration files.

   > YAML files are named after the environment they belong to.
   >
   > | Environment | YAML file                |
   > | ----------- | ------------------------ |
   > | Review apps | [review_app_env.yml]     |
   > | QA          | [qa_app_env.yml]         |
   > | Staging     | [staging_app_env.yml]    |
   > | Sandbox     | [sandbox_app_env.yml]    |
   > | Production  | [production_app_env.yml] |

[review_app_env.yml]: /terraform/application/config/review_app_env.yml
[qa_app_env.yml]: /terraform/application/config/qa_app_env.yml
[staging_app_env.yml]: /terraform/application/config/staging_app_env.yml
[sandbox_app_env.yml]: /terraform/application/config/sandbox_app_env.yml
[production_app_env.yml]: /terraform/application/config/production_app_env.yml

3. Commit your changes, open a pull request, and merge it into `main`.
4. Environment variables will be deployed as part of the usual CI/CD pipeline.
