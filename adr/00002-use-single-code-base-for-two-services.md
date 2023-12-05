# 1. Record architecture decisions

Date: 2023-12-01

## Status

Accepted

## Context

There are lots of interdependencies between the track-and-pay and school placement services.
Three workshops took place over the w/c 27 December to consider those interdependencies and make decisions about how the teams should manage those.

## Decision

The teams, in consultation with the staff engineer, technical architect, and technical lead from the register service, agreed that the two services should be co-located in a single application and codebase.

## Consequences

The two service teams will need to work in close collaboration and coordination.
