# School region calculations

Within the claims application, we have a need to calculate a schools funding per hour. This is so when a mentor completes their training we have a way to calculate their hourly rate, which they then can recoup.

```
  claims_funding_available_per_hour_pence = region.claims_funding_available_per_hour_pence

  total_hours_completed = claim.mentor_trainings.sum(:hours_completed)

  amount_in_pence = claims_funding_available_per_hour_pence * total_hours_completed
```

## Data model

We have a data model in place where a [School](https://github.com/DFE-Digital/itt-mentor-services/blob/main/db/schema.rb#L281) belongs to a [Region](https://github.com/DFE-Digital/itt-mentor-services/blob/main/db/schema.rb#L263), a Region can have many schools associated to it.

```mermaid
erDiagram
    REGION ||--o{ SCHOOL : "Has many"
    REGION {
        uuid id
        string name
        integer claims_funding_available_per_hour_pence
        string claims_funding_available_per_hour_currency
        datetime created_at
        datetime updated_at
    }
    SCHOOL {
        uuid id
        string urn
        boolean placements_service
        boolean claims_service
        string name
        string postcode
        string town
        string ukprn
        string telephone
        string website
        string address1
        string address2
        string address3
        string group
        string type_of_establishment
        string phase
        string gender
        integer minimum_age
        integer maximum_age
        string religious_character
        string admissions_policy
        string urban_or_rural
        integer school_capacity
        integer total_pupils
        integer total_girls
        integer total_boys
        integer percentage_free_school_meals
        string special_classes
        string send_provision
        string training_with_disabilities
        string rating
        date last_inspection_date
        string email_address
        string district_admin_name
        string district_admin_code
        uuid region_id
        uuid trust_id
        float longitude
        float latitude
        string local_authority_name
        string local_authority_code
        datetime claims_grant_conditions_accepted_at
        uuid claims_grant_conditions_accepted_by_id
    }
```

## Associating Schools to Regions

We have an overnight process which syncs across schools from GIAS, in this process it also does the associating of a School to a given Region. The way this is done is we use the Schools `district_admin_code` to define which Region it should go in. These are mapped out [here](https://github.com/DFE-Digital/itt-mentor-services/blob/main/app/services/concerns/regional_areas.rb) where each `district_admin_code` is related to a specific region.

## Calculating the hourly rate

Once all associating has taken place we can then query what the hourly rate will be by doing `school.region.funding_available_per_hour` [here](https://github.com/DFE-Digital/itt-mentor-services/blob/main/app/models/region.rb) which will then derive the funding per hour.
