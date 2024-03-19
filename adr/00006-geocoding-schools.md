# 6. Use Geocoder gem to Geocode Schools

Date: 2024-03-19

## Status

Accepted

## Context

We want to add longitude and latitude attributes to our `School` records, so we can search for schools within a given area (e.g 10 miles from London, United Kingdom).

## Decision

We have decided to use the [Geocoder](https://github.com/alexreisner/geocoder) gem to geocode our `School` records. Geocoding is based of the address attributes assigned to a school.

__School Address Attributes__
- Address1
- Address2
- Address3
- Town
- Postcode

## How it works

Using the method `geocode` on a `School` record will dispatch an API call to an external provider, and retrieve the longitude and latitude of the school based on the schools's _School Address Attributes_. The retrieved longitude and latitude values are then assigned to the respective attributes in the `School` record.

_(We have hardcoded the address method in the `School` model to only reference addresses within the **United Kingdom**)_

## Consequences

- Due to our decision to use the `upsert_all` method in the `Gias::CsvImporter` service, the validation callback in the `School` model will not trigger the `geocode` method when creating or updating a school using the `Gias::CsvImporter` service. As a result we have implemented the `Geocoder::UpdateAllSchools` service and `Geocoder::UpdateAllSchoolsJob` job to run as part of the `Gias::SyncAllSchoolsJob` job, to geocode all un-geocoded schools.

- If any of a school's _School Address Attributes_ were to be updated as a result of the `Gias::SyncAllSchoolsJob` job, the school record will not be re-geocoded, as the school record has already been geocoded. To re-geocode the school record, you will need to run the `geocode` method on the updated school manually from the Rails console. _(However, we find it unlikely that a school will change its address drastically enough to warrant re-geocoding upon a change to the School Address Attributes)_
