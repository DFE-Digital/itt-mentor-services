# HTTP interfaces and file contracts

[Claims documentation](README.md)

## Scope and authentication

The application is primarily a server-rendered service. The JSON endpoints below support browser suggestions. They are not a documented public claims-management API.

Routes are declared in [shared routes](../../config/routes.rb). Requests must use the claims hostname selected by [HostingEnvironment](../../lib/hosting_environment.rb). These controllers inherit [ApplicationController](../../app/controllers/application_controller.rb), including session authentication. An unauthenticated request redirects to `/sign-in`; it does not have a bespoke JSON `401` contract. No separate bearer-token scheme is implemented in these controllers.

## Endpoint reference

All three endpoints use `GET` and require a non-empty `query` parameter. The query is lowercased before search. Results are JSON arrays with a maximum of **50** records. Empty search results are `[]`; there is no pagination contract.

| Path | Search and filtering | Response fields |
| --- | --- | --- |
| `/api/school_suggestions` | School name, URN or postcode | `id`, `name`, `town`, `postcode` |
| `/api/provider_suggestions` | Provider name, URN, UKPRN or postcode; current academic year | `id`, `name`, `postcode`, `code` |
| `/api/academic_years/:academic_year_id/provider_suggestions` | Same search, using the supplied academic year UUID | `id`, `name`, `postcode`, `code` |

Claims provider results exclude additional NIoT provider sites and require provider eligibility for the selected year. The `accredited` flag alone does not determine inclusion. Without the year path parameter the controller uses `AcademicYear.current`, not an arbitrary claim window.

Sources: [school controller](../../app/controllers/api/school_suggestions_controller.rb), [provider controller](../../app/controllers/api/provider_suggestions_controller.rb), [provider request specs](../../spec/requests/api/provider_suggestions_spec.rb).

### Sanitised example

With an existing authenticated browser session on the claims host:

```http
GET /api/provider_suggestions?query=example
Accept: application/json
```

Illustrative response shape, not live data or a stable ordering guarantee:

```json
[
  {
    "id": "00000000-0000-4000-8000-000000000001",
    "name": "Example provider",
    "postcode": null,
    "code": "EX1"
  }
]
```

School results use `town` instead of `code`. Text address fields may be null. IDs are local database UUIDs, not provider codes or school URNs.

### Errors and compatibility

| Condition | Implementation behaviour |
| --- | --- |
| Missing or empty `query` | `params.require(:query)` raises `ActionController::ParameterMissing`; normally HTTP 400 under Rails exception handling |
| Unknown academic year | `AcademicYear.find` raises `ActiveRecord::RecordNotFound`; normally HTTP 404. Request specs assert the exception |
| No eligible providers | Successful empty array |
| Not signed in | Redirect to sign-in |

Development/test exception presentation can differ from production. There is no custom JSON error envelope in these controllers.

These inbound paths are unversioned. No endpoint-specific application rate limiter was found in the routes, controllers or initializers inspected for this audit. **That is not a guarantee of unlimited requests:** edge/platform limits and an agreed compatibility policy need confirmation. Do not confuse the 50-result cap with request-rate limiting, or outbound Teaching Record limits with inbound API limits.

## Other interfaces

| Interface | Contract source |
| --- | --- |
| School/provider/support HTML journeys | [Claims routes](../../config/routes/claims.rb) and [policies](../../app/policies/claims/) |
| Payment, sampling and clawback files | [Lifecycle and CSV contracts](claim-lifecycle.md#payment-and-assurance-exchanges) |
| Payment/sampling/clawback downloads | Claims route namespaces and [controllers](../../app/controllers/claims/); check each action's access controls, not just suggestion endpoint authentication |
| Operational health | [Operations](operations.md#health-and-telemetry) |
| Outbound third-party APIs | [Integration register](integrations.md) |

No OpenAPI generator is configured for these interfaces in the inspected documentation/workflows. Keep this Markdown reference in step with routes, controller selection fields and request specs. A machine-readable specification can be a separate decision if external consumers require it.
