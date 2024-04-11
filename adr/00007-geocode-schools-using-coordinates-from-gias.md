# 7. Geocode schools using coordinates from GIAS

Date: 2024-04-11

## Status

Accepted

## Context

We originally planned to geocode schools using an external geocoding service – namely, the Google Maps [Geocoding API](https://developers.google.com/maps/documentation/geocoding/overview) – as per [ADR 6](00006-geocoding-schools.md).

However the Geocoding API terms of use are quite restrictive for our needs. Specifically, the following two clauses are challenging:

1. #### [Pre-fetching, caching, or storage of content](https://developers.google.com/maps/documentation/geocoding/policies#cache-policy)

   Google specifies that geocoded latitude/longitude results can only be stored for up to 30 days.

   This means that all GIAS schools within the service would need to be re-geocoded every month. At 20k schools, that'd be an expensive operation to perform monthly.

2. #### [Displaying Geocoding API results](https://developers.google.com/maps/documentation/geocoding/policies#logo)

   Any information which is derived from Geocoding API results must be attributed to Google. This can be done by embedding a Google Map on the same page, or by prominently displaying the Google logo on screen.

   Currently the School Placements service does not include embedded Google Maps nor any attribution to Google. UI changes will be required to add these if we depend on Geocoding API results – for example when displaying "X miles from you" in search results.

### Grid coordinates in the GIAS dataset

Instead of using an external geocoding service, we could make use of the geo coordinates available to us in the GIAS dataset.

The GIAS dataset provides coordinates for schools as Easting and Northing values. These are grid coordinates for the [Ordnance Survey National Grid](https://en.wikipedia.org/wiki/Ordnance_Survey_National_Grid) reference system (OSGB).

However our app needs coordinates to be in Latitude and Longitude format, for use with [geocoder](https://www.rubygeocoder.com/) and any other geolocation or mapping tools. It would therefore be necessary for us to convert these Easting/Northing coordinates into Latitude/Longitude values.

### Converting Easting/Northing to Latitude/Longitude

[PROJ](https://proj.org) is a generic coordinate transformation software that transforms geospatial coordinates from one coordinate reference system (CRS) to another.

We can use PROJ to convert Easting/Northing values to Latitude/Longitude. This is the underlying software used by other geospatially aware tools such as [PostGIS](https://postgis.net/docs/ST_Transform.html).

## Decision

We will use the coordinates provided by GIAS to geolocate schools.

We'll do this by converting Easting/Northing values to Latitude/Longitude during the [GIAS CSV import process](https://github.com/DFE-Digital/itt-mentor-services/blob/dbbc22de1cb1f33b2ee41397347fd71c6ac353e3/app/jobs/gias/sync_all_schools_job.rb).

## Consequences

- PROJ will become a dependency of the app. That will need to be reflected in the relevant places – for example, in the [Dockerfile](/Dockerfile), the [CI workflow](/.github/workflows/build_and_test.yml), and any developer-facing documentation.
- We will no longer need to geocode schools using the geocoder gem and an external geocoding service.
- Note: we will likely still need the ability to geocode addresses using an external API – for example, to geocode location-based search queries from users. But that is outside the scope of this ADR – this ADR is only concerned with the geocoding of schools.
