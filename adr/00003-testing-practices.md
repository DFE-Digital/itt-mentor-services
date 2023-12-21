# 3. Testing Practices

Date: 2023-12-14

## Status

Accepted

## Context

We want to align developers testing practices. Without alignment, we're unsure about how to add tests for specific functionality groups.

## Decision

Use the following test types for our classes, modules, and functionalities.

- Models, Background Jobs, and Service Objects require Unit tests for all added methods.

  ```ruby
  RSpec.describe User, type: :model do
    subject { build(:user) }

    describe ".class_method" do
      it "does something" do
        expect(User.class_method).to do_something
      end
    end

    describe "#instance_method" do
      it "does something" do
        expect(subject.instance_method).to do_something
      end
    end
  end
  ```

  ```ruby
  RSpec.describe CreateUser do
    describe ".class_method" do
      it "does something" do
        expect(User.class_method).to do_something
      end
    end

    describe "#instance_method" do
      it "does something" do
        expect(subject.instance_method).to do_something
      end
    end
  end
  ```

- User flows should have their functionality tested via System specs.

  ```ruby
  # spec/system/submit_claim_spec.rb
  RSpec.describe "Submit Claim", type: :system do
    scenario "A user submits a claim" do
      given_i_am_on_the_landing_page
      i_can_see_something
    end

    def given_i_am_on_the_landing_page
      visit "/"
    end

    def i_can_see_something
      expect(page).to have_content("Something")
    end
  end
  ```

- API endpoints should have their functionality tested in Request specs.

  For API specs, we need to test variants of inputs to their responses.

  ```ruby
  RSpec.describe "Users", type: :request do
    # Follow the Rails' default %[index create show update destroy] order
    context "GET /users" do
      # Base happy path first
      it "returns a list of users" do
        get :index

        expected_json = [
          {
            id: 1,
            first_name: "John",
            last_name: "Doe"
          }
        ]

        expect(response.body).to eq(expected_json)
      end

      # Happy path variants next
      context "when given a 'name' query parameter" do
        it "returns a list of users filtered by name" do
          # Assertion
        end
      end

      # Error paths
      context "without authentication" do
        it "returns a 401 error" do
          # Assertion
        end
      end
    end

    context "POST /users" do
      it "returns a list of users" do
        get :index
      end
    end
  end
  ```

## Consequences

Alignment of testing patterns within the app. Quicker and more aligned reviews.

Drawbacks being new testing patterns should also be aligned on and will require additional collaboration.
