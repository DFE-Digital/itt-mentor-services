# Architecture decision records

Records preserve decisions made at the time. An accepted historical record is not a complete specification of the current application. Use the [claims architecture](../docs/claims/architecture.md) and [data model](../docs/claims/data-model.md) for current implementation.

| Record | Current reading guidance |
| --- | --- |
| [1. Record architecture decisions](00001-record-architecture-decisions.md) | Defines the ADR approach. |
| [2. Single codebase for two services](00002-use-single-code-base-for-two-services.md) | Historical shared-codebase decision. The file's heading repeats record 1; retain the historical text rather than silently rewriting it. Claims is now the service listed in the root README, while placements code/data remain. |
| [3. Testing practices](00003-testing-practices.md) | Unit, system and request testing responsibilities. |
| [4. Stimulus](00004-use-stimulus-as-our-javascript-framework.md) | Behaviour-oriented JavaScript enhancement. |
| [5. Pundit](00005-user-authorisation-using-pundit.md) | Policy-based authorisation. Read current controller enforcement and namespaces too. |
| [6. Geocoder](00006-geocoding-schools.md) | Historical school geocoding approach; read record 7 before applying it. |
| [7. GIAS coordinates](00007-geocode-schools-using-coordinates-from-gias.md) | Replaces the school-geocoding approach with GIAS coordinates and PROJ conversion. |
| [8. School email task](00008-populate-school-emails-via-task.md) | Manual email-data dependency. Confirm the current data supplier and cadence; the historical frequency is not a live-service schedule. |
| [9. Wizards](00009-wizards.md) | Explains controller-independent wizards and session state. Examples predate parts of the current implementation. |
| [10. Claims school onboarding](00010-onboarding-claims-schools.md) | Eligibility rationale; the proposed school-to-window schema differs from the current academic-year eligibility model. Do not copy its training allowance figures as current policy. |
| [11. Private beta features](00011-private-beta-features.md) | Placements feature/journey record, not a claims specification or a conventional accepted ADR. |

## Adding a decision

Use the existing numbered filename convention and context, decision, status and consequences structure. The [root README](../README.md#how-the-application-works) documents the `rladr` command.

For a retrospective ADR:

1. Mark it **Retrospective** and distinguish the date recorded from any verified decision date.
2. Link implementation evidence and identify which rationale the outgoing team has confirmed.
3. Leave unconfirmed rationale explicit. Do not mark the record accepted on the strength of source code alone.
4. Link replacement decisions instead of silently changing historical records.

Potential uncovered decisions include GoodJob/Postgres job storage, analytics replication and the operational model for financial CSV exchanges. No new accepted ADR has been invented for this handover. Confirm rationale and approval through [audit gap G12](../docs/claims/documentation-audit.md#team-input-register) first.

The rationale was asked about during the October 2026 handover and is unknown to the current respondent. Seek historical evidence or the original decision makers rather than inferring the reasons from the implementation.
