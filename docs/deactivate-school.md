# Deactivate school

## Purpose
This document describes how to 'deactivate' a school from either the claims and/or placements service. 
This is not a process which can be performed within either live service. This code will need to be executed within the `rails console` on an Azure server running this service.

To connect to the Azure server, please follow the instructions [Connect to an instance running in Azure](/docs/connect-to-azure)

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