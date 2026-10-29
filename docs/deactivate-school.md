# Deactivate school

## Purpose
This document describes how to 'deactivate' a school from either the claims and/or placements service. 
This is not a process which can be performed within either live service. This code will need to be executed within the `rails console` on an Azure server running this service.

To connect to the Azure server, please follow [Connect to an instance running in Azure](connect-to-azure.md).

> [!CAUTION]
> This is destructive data deletion, not a reversible account-disable operation. Obtain approval, confirm the environment and school identity, inspect associated data and agree recovery before running it. Do not execute it to validate this guide.
>
> The source of truth is [SupportHelper](../app/support_tools/support_helper.rb). Its claims guard accepts only `draft` and `submitted` claims. It also rejects `internal_draft` or any other status. Never bypass that guard by changing statuses.

## Deactivating the school from the claims service

```ruby
SupportHelper.deactivate_school(school: school, claims_service: true)
```
(Assuming the school you wish to deactivate is assigned to the variable `school`)

Executing this code will perform the following:

- Destroy all `claims` associated with the `school`.
- Destroy all `eligibilities` associated with the `school`.
- Destroy all `mentor_memberships` associated with the `school`.
- Destroy all `user_memberships` associated with the `school`.
- Update the `claims_service` attribute on the `school` to `false`.

This will effectively deactivate the school from the claims service.

After an approved change, verify the school's `claims_service` flag is false and the scoped claims, eligibility and membership records were removed as expected. Check unintended side effects before closing the support request. If results differ, stop and escalate; do not retry deletion blindly.

:warning: Warning :warning:
If the `school` has associated `claims`, which are not in either the `draft` or `submitted` state. 
Then school can not be deactivated from the claims service.

## Deactivating the school from the placements service

```ruby
SupportHelper.deactivate_school(school: school, placements_service: true)
```
(Assuming the school you wish to deactivate is assigned to the variable `school`)

Executing this code will perform the following:

- Destroy all `placements` associated with the `school`.
- Destroy all `mentor_memberships` associated with the `school`.
- Destroy all `user_memberships` associated with the `school`.
- Destroy all `partnerships` associated with the `school`.
- Destroy all `hosting_interests` associated with the `school`.
- Update the `placements_service` attribute on the `school` to `false`.

This will effectively deactivate the school from the placements service.

:warning: Warning :warning:
If the `school` has associated `placements`, which are have been associated with a `provider`. 
Then school can not be deactivated from the placements service.

## Deactivating the school from both services

```ruby
SupportHelper.deactivate_school(school: school, claims_service: true, placements_service: true)
```

Executing this code will perform all of the functions listed above for both services.
This will effectively remove the school from both the claims and placements service.