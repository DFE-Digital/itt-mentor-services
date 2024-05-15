# 8. Populating school emails via rake task

Date: 2024-05-11

## Status

Accepted

## Context

When we import school data from GIAS, we DO NOT import the schools email in the overnight GIAS sync due to the data not being present in GIAS. However we wanted these emails for a way to send out initial communications to onboard their first user to the Funding Mentors service, this could also be used for other purposes in the future.

## Decision

We have a decided to create a separate task `lib/tasks/update_school_emails.rake` which can be run on an ad-hoc basis, which will populate the schools emails based off a CSV file. (We have been told we will run this every 6 months)

## Consequences

- This is a manual process, and if no devs are around this data could become outdated.
- Since this is a manual process on GIAS's side, we may need to manually request this information from them, which creates a dependency.
