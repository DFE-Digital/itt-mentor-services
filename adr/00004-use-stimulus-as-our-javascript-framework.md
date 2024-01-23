# 4. Use Stimulus as our Javascript framework

Date: 2024-01-23

## Status

Accepted

## Context

We want to better organise our JavaScript. Stimulus is the default JavaScript framework for Rails and offers a lot more control then not having a JavaScript framework. It allows us to choose which pages or html elements do need a bit JavaScript.

## Decision

Use Stimulus controllers to enhance html elements or pages. This can be done via the stimulus-rails gem.
- https://stimulus.hotwired.dev/
- https://github.com/hotwired/stimulus-rails

We should follow the Rails conventions on name spacing/folder structure, a Stimulus controller can be reused in any view or just one view. We should create behaviour-driven controllers, not context-driven ones.

For example: `autocomplete-controller` not `schools-select-controller`. The former can then be configured to be used in multiple pages.

## Consequences

As with any JavaScript framework or any code, there is a possibility of adding a lot of code and things can get hard to maintain. Luckily our app doesn't require too much JavaScript.
