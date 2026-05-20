# Provider Claims User Research Prototype
This prototype provides a self-contained flow for provider user research without relying on DfE Sign-in or production claim records.
## Journey
1. Open `GET /user-research/provider-session/new`
2. Sign in with invite-style credentials
3. View a list of provider claims
4. Open a claim to view a support-style claim details page
## Routes
- `new_claims_user_research_provider_session_path`
- `claims_user_research_provider_session_path` (`POST` and `DELETE`)
- `claims_user_research_provider_claims_path`
- `claims_user_research_provider_claim_path(id)`
## Prototype credentials
- Code: `BPN01`
  - Email: `research+best-practice-network@example.org`
- Code: `NIOT1`
  - Email: `research+niot@example.org`
## Data source
All prototype data is in-memory in `app/services/claims/user_research/provider_claims_prototype.rb`.
