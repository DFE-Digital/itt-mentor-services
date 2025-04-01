# Private Beta Features

## Schools

1. Add expression of interest flow
2. Add bulk adding placements
3. Add ability to update hosting interests
4. Add mixed year group option when creating placements
5. Remove the providers tab
6. Update the provider assignment for placements to be for any provider in the service
7. Add academic year switcher

```mermaid
flowchart TD

user_logs_in{{User logs in}}
interest_registered([Has interest been registered?])
user_registers_interest{{"★ User registers interest (1)"}}
user_views_placements{{User views placements}}
user_views_users{{User views all users}}
user_views_a_user{{User views a user}}
user_adds_a_user{{User adds a user}}
user_removes_a_user{{User removes a user}}
user_views_mentors{{User views all mentors}}
user_views_a_mentor{{User views a mentor}}
user_adds_a_mentor{{User adds a mentor}}
user_removes_a_mentor{{User removes a mentor}}
user_views_org_details{{User views organisation details}}
user_changes_hosting_interest{{"★ User changes hosting interest (3)"}}
user_changes_academic_year{{"★ User changes academic year (7)"}}
user_adds_placements{{"★ User adds placements (2, 4)"}}
user_views_a_placement{{User views a placement}}
user_edits_placement_provider{{"★ User edits placement provider (6)"}}
user_edits_placement_mentor{{User edits placement mentor}}
user_edits_placement_expected_date{{User edits placement expected date}}
user_edits_year_group{{User edits placement year group}}
user_removes_placement{{User removes a placement}}

user_logs_in --> interest_registered
interest_registered -- no --> user_registers_interest
interest_registered -- yes --> user_views_placements
user_registers_interest --> user_views_placements
user_views_placements --> user_views_users
user_views_users --> user_views_a_user
user_views_a_user --> user_removes_a_user
user_views_users --> user_adds_a_user
user_views_placements --> user_views_mentors
user_views_mentors --> user_views_a_mentor
user_views_a_mentor --> user_removes_a_mentor
user_views_mentors --> user_adds_a_mentor
user_views_placements --> user_views_org_details
user_views_org_details --> user_changes_hosting_interest
user_views_placements --> user_changes_academic_year
user_views_placements --> user_adds_placements
user_views_placements --> user_views_a_placement
user_views_a_placement --> user_edits_placement_provider
user_views_a_placement --> user_edits_placement_mentor
user_views_a_placement --> user_edits_placement_expected_date
user_views_a_placement --> user_edits_year_group
user_views_a_placement --> user_removes_placement

```


## Providers

1. Add find a school page
2. Remove find placements page
3. Import data from the register service to show previously hosted placements for schools
4. Add ability to view placements that have been assigned to the provider
5. Add academic year switcher

```mermaid
flowchart TD

user_logs_in{{User logs in}}
user_finds_a_school{{"★ User finds a school (1, 3)"}}
user_views_users{{User views all users}}
user_views_a_user{{User views a user}}
user_adds_a_user{{User adds a user}}
user_removes_a_user{{User removes a user}}
user_views_schools{{User views all schools}}
user_views_a_school{{User views a school}}
user_adds_a_school{{User adds a school}}
user_removes_a_school{{User removes a school}}
user_views_org_details{{User views organisation details}}
user_changes_academic_year{{"★ User changes academic year (5)"}}
user_views_placements{{"★ User views placements assigned to them (4)"}}

user_logs_in --> user_finds_a_school
user_finds_a_school --> user_views_users
user_views_users --> user_views_a_user
user_views_a_user --> user_removes_a_user
user_views_users --> user_adds_a_user
user_finds_a_school --> user_views_schools
user_views_schools --> user_views_a_school
user_views_a_school --> user_removes_a_school
user_views_schools --> user_adds_a_school
user_finds_a_school --> user_views_org_details
user_finds_a_school --> user_changes_academic_year
user_finds_a_school --> user_views_placements
```
