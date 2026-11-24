require "rails_helper"

RSpec.describe Placements::Schools::SummaryComponent, type: :component do
  subject(:component) do
    described_class.new(school:, provider:, academic_year:)
  end

  let(:provider) { create(:placements_provider) }
  let(:hosting_interests) { [] }
  let(:placements) { [] }
  let(:school_contact) { build(:school_contact) }
  let(:academic_year) { Placements::AcademicYear.current }
  let(:school) do
    create(:placements_school,
           hosting_interests:,
           placements:,
           school_contact:,
           phase: "All-through",
           name: "Hogwarts",
           group: "Local authority maintained schools",
           minimum_age: 5,
           maximum_age: 11,
           longitude: -3.0581722753,
           latitude: 52.8409318812,
           address1: "Magical Lane",
           postcode: "SW1A 1AA",
           town: "London")
  end

  before do
    allow(school).to receive_messages(distance_to: 42, drive_travel_duration: "15 mins", transit_travel_duration: "30 mins", walk_travel_duration: "45 mins")
    render_inline(component)
  end

  context "when publishing without a hosting interest" do
    let(:school) { create(:placements_school, with_hosting_interest: false, placements:, name: "Hogwarts") }
    let(:placements) { [build(:placement, academic_year:)] }

    it "links the school name to its placements" do
      expect(page).to have_link("Hogwarts", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      expect(page).to have_text("Placements available")
      expect(page).to have_link("1 unfilled placement")
    end
  end

  context "when the school is open to hosting" do
    context "when the school does not have any placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "interested") }

      it "displays the school's hosting interest" do
        expect(page).to have_text("May offer placements")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      end

      it "displays the school's name" do
        expect(page).to have_text("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_text("School details")
        expect(page).to have_text("Phase (age range)")
        expect(page).to have_text("All-through (5 to 11)")
        expect(page).to have_text("Establishment group")
        expect(page).to have_text("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_text("Placement information")
        expect(page).to have_text("Unfilled placements")
        expect(page).to have_text("SEND placements")
        expect(page).to have_link("Approximate information available", href: "/providers/#{provider.id}/find/#{school.id}/placements")
        expect(page).to have_text("Last offered")
        expect(page).to have_text("This school has not previously hosted placements")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_text("Getting there")
          expect(page).to have_text("Address")
          expect(page).to have_text("Magical Lane")
          expect(page).to have_text("London")
          expect(page).to have_text("SW1A 1AA")
          expect(page).to have_text("Distance")
          expect(page).to have_text("42 miles")
          expect(page).to have_text("Travel time")
          expect(page).to have_text("30 minutes by public transport")
          expect(page).to have_text("15 minutes drive")
          expect(page).to have_text("45 minutes walk")
        end
      end
    end

    context "when the school has unfilled placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "actively_looking") }

      let(:placements) { build_list(:placement, 1) }

      it "displays the school's hosting interest" do
        expect(page).to have_text("Placements available")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      end

      it "displays the school's name" do
        expect(page).to have_text("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_text("School details")
        expect(page).to have_text("Phase (age range)")
        expect(page).to have_text("All-through (5 to 11)")
        expect(page).to have_text("Establishment group")
        expect(page).to have_text("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_text("Placement information")
        expect(page).to have_text("Unfilled placements")
        expect(page).to have_text("SEND placements")
        expect(page).to have_link("1 unfilled placement", href: "/providers/#{provider.id}/find/#{school.id}/placements")
        expect(page).to have_text("Last offered")
        expect(page).to have_text("This school has not previously hosted placements")
      end

      it "displays the getting there section", :aggregate_failures do
        expect(page).to have_text("Getting there")
        expect(page).to have_text("Address")
        expect(page).to have_text("Magical Lane")
        expect(page).to have_text("London")
        expect(page).to have_text("SW1A 1AA")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_text("Getting there")
          expect(page).to have_text("Address")
          expect(page).to have_text("Magical Lane")
          expect(page).to have_text("London")
          expect(page).to have_text("SW1A 1AA")
          expect(page).to have_text("Distance")
          expect(page).to have_text("42 miles")
          expect(page).to have_text("Travel time")
          expect(page).to have_text("30 minutes by public transport")
          expect(page).to have_text("15 minutes drive")
          expect(page).to have_text("45 minutes walk")
        end
      end
    end

    context "when the school has unfilled and filled placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "actively_looking") }
      let(:placements) { [build(:placement, provider:), build(:placement)] }

      it "displays the school's hosting interest" do
        expect(page).to have_text("Placements available")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      end

      it "displays the school's name" do
        expect(page).to have_text("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_text("School details")
        expect(page).to have_text("Phase (age range)")
        expect(page).to have_text("All-through (5 to 11)")
        expect(page).to have_text("Establishment group")
        expect(page).to have_text("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_text("Placement information")
        expect(page).to have_text("Unfilled placements")
        expect(page).to have_text("SEND placements")
        expect(page).to have_link("1 unfilled placement", href: "/providers/#{provider.id}/find/#{school.id}/placements")
        expect(page).to have_text("Hosting subjects")
        expect(page).to have_text("1 filled placement")
        expect(page).to have_text("Last offered")
        expect(page).to have_text("This school has not previously hosted placements")
      end

      it "displays the getting there section", :aggregate_failures do
        expect(page).to have_text("Getting there")
        expect(page).to have_text("Address")
        expect(page).to have_text("Magical Lane")
        expect(page).to have_text("London")
        expect(page).to have_text("SW1A 1AA")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_text("Getting there")
          expect(page).to have_text("Address")
          expect(page).to have_text("Magical Lane")
          expect(page).to have_text("London")
          expect(page).to have_text("SW1A 1AA")
          expect(page).to have_text("Distance")
          expect(page).to have_text("42 miles")
          expect(page).to have_text("Travel time")
          expect(page).to have_text("30 minutes by public transport")
          expect(page).to have_text("15 minutes drive")
          expect(page).to have_text("45 minutes walk")
        end
      end
    end

    context "when the school only has filled placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "actively_looking") }
      let(:placements) { build_list(:placement, 1, provider:) }

      it "displays the school's hosting interest" do
        expect(page).to have_text("No placements available")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      end

      it "displays the school's name" do
        expect(page).to have_text("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_text("School details")
        expect(page).to have_text("Phase (age range)")
        expect(page).to have_text("All-through (5 to 11)")
        expect(page).to have_text("Establishment group")
        expect(page).to have_text("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_text("Placement information")
        expect(page).to have_text("SEND placements")
        expect(page).to have_text("Hosting subjects")
        expect(page).to have_text("1 filled placement")
        expect(page).to have_text("Last offered")
        expect(page).to have_text("This school has not previously hosted placements")
      end

      it "displays the getting there section", :aggregate_failures do
        expect(page).to have_text("Getting there")
        expect(page).to have_text("Address")
        expect(page).to have_text("Magical Lane")
        expect(page).to have_text("London")
        expect(page).to have_text("SW1A 1AA")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_text("Getting there")
          expect(page).to have_text("Address")
          expect(page).to have_text("Magical Lane")
          expect(page).to have_text("London")
          expect(page).to have_text("SW1A 1AA")
          expect(page).to have_text("Distance")
          expect(page).to have_text("42 miles")
          expect(page).to have_text("Travel time")
          expect(page).to have_text("30 minutes by public transport")
          expect(page).to have_text("15 minutes drive")
          expect(page).to have_text("45 minutes walk")
        end
      end
    end

    context "when the school has previously hosted placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "interested") }
      let(:previous_academic_year) { Placements::AcademicYear.current.previous }
      let(:placements) { build_list(:placement, 1, academic_year: previous_academic_year, provider:) }

      it "displays the school's hosting interest" do
        expect(page).to have_text("May offer placements")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      end

      it "displays the school's name" do
        expect(page).to have_text("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_text("School details")
        expect(page).to have_text("Phase (age range)")
        expect(page).to have_text("All-through (5 to 11)")
        expect(page).to have_text("Establishment group")
        expect(page).to have_text("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_text("Placement information")
        expect(page).to have_text("Last offered")
        expect(page).to have_text("1 subject in #{previous_academic_year.name}")
      end

      it "displays the getting there section", :aggregate_failures do
        expect(page).to have_text("Getting there")
        expect(page).to have_text("Address")
        expect(page).to have_text("Magical Lane")
        expect(page).to have_text("London")
        expect(page).to have_text("SW1A 1AA")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_text("Getting there")
          expect(page).to have_text("Address")
          expect(page).to have_text("Magical Lane")
          expect(page).to have_text("London")
          expect(page).to have_text("SW1A 1AA")
          expect(page).to have_text("Distance")
          expect(page).to have_text("42 miles")
          expect(page).to have_text("Travel time")
          expect(page).to have_text("30 minutes by public transport")
          expect(page).to have_text("15 minutes drive")
          expect(page).to have_text("45 minutes walk")
        end
      end
    end
  end

  context "when the school has historically hosted placements" do
    let(:school) do
      create(:placements_school,
             hosting_interests:,
             placements:,
             school_contact:,
             phase: "All-through",
             name: "Hogwarts",
             group: "Local authority maintained schools",
             minimum_age: 5,
             maximum_age: 11,
             longitude: -3.0581722753,
             latitude: 52.8409318812,
             address1: "Magical Lane",
             postcode: "SW1A 1AA",
             town: "London",
             previously_offered_placements: true)
    end

    it "displays the school's hosting interest" do
      expect(page).to have_text("Placement availability unknown")
    end

    it "displays the school's name" do
      expect(page).to have_text("Hogwarts")
    end

    it "displays the school's details", :aggregate_failures do
      expect(page).to have_text("School details")
      expect(page).to have_text("Phase (age range)")
      expect(page).to have_text("All-through (5 to 11)")
      expect(page).to have_text("Establishment group")
      expect(page).to have_text("Local authority maintained schools")
    end

    it "displays placement information", :aggregate_failures do
      expect(page).to have_text("Placement information")
      expect(page).to have_text("Last offered")
      expect(page).to have_text("This school has previously hosted placements")
    end

    it "displays the getting there section", :aggregate_failures do
      expect(page).to have_text("Getting there")
      expect(page).to have_text("Address")
      expect(page).to have_text("Magical Lane")
      expect(page).to have_text("London")
      expect(page).to have_text("SW1A 1AA")
    end
  end

  context "when the school is not open to hosting" do
    let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "not_open") }

    it "displays the school's hosting interest" do
      expect(page).to have_text("Not offering placements")
    end

    it "displays the school's name" do
      expect(page).to have_text("Hogwarts")
    end

    it "displays the school's details", :aggregate_failures do
      expect(page).to have_text("School details")
      expect(page).to have_text("Phase (age range)")
      expect(page).to have_text("All-through (5 to 11)")
      expect(page).to have_text("Establishment group")
      expect(page).to have_text("Local authority maintained schools")
    end

    it "displays placement information", :aggregate_failures do
      expect(page).to have_text("Placement information")
      expect(page).to have_text("Last offered")
      expect(page).to have_text("This school has not previously hosted placements")
    end

    it "displays the getting there section", :aggregate_failures do
      expect(page).to have_text("Getting there")
      expect(page).to have_text("Address")
      expect(page).to have_text("Magical Lane")
      expect(page).to have_text("London")
      expect(page).to have_text("SW1A 1AA")
    end

    it "displays a message indicating the school doesn't want to be contacted" do
      expect(page).to have_text("This school does not wish to be contacted this academic year.")
    end

    context "when location coordinates have been provided" do
      subject(:component) do
        described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
      end

      it "displays the getting there section", :aggregate_failures do
        expect(page).to have_text("Getting there")
        expect(page).to have_text("Address")
        expect(page).to have_text("Magical Lane")
        expect(page).to have_text("London")
        expect(page).to have_text("SW1A 1AA")
        expect(page).to have_text("Distance")
        expect(page).to have_text("42 miles")
        expect(page).to have_text("Travel time")
        expect(page).to have_text("30 minutes by public transport")
        expect(page).to have_text("15 minutes drive")
        expect(page).to have_text("45 minutes walk")
      end
    end
  end

  context "when the school has not registered a hosting interest" do
    it "does not display a hosting interest" do
      expect(page).to have_no_text("Not hosting")
      expect(page).to have_no_text("Open to hosting")
      expect(page).to have_no_text("Already organised placements")
      expect(page).to have_no_text("Unfilled placements")
    end

    it "displays the school's name" do
      expect(page).to have_text("Hogwarts")
    end

    it "displays the school's details", :aggregate_failures do
      expect(page).to have_text("School details")
      expect(page).to have_text("Phase (age range)")
      expect(page).to have_text("All-through (5 to 11)")
      expect(page).to have_text("Establishment group")
      expect(page).to have_text("Local authority maintained schools")
    end

    it "displays placement information", :aggregate_failures do
      expect(page).to have_text("Placement information")
      expect(page).to have_text("Last offered")
      expect(page).to have_text("This school has not previously hosted placements")
    end

    context "when location coordinates have been provided" do
      subject(:component) do
        described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
      end

      it "displays the getting there section", :aggregate_failures do
        expect(page).to have_text("Getting there")
        expect(page).to have_text("Address")
        expect(page).to have_text("Magical Lane")
        expect(page).to have_text("London")
        expect(page).to have_text("SW1A 1AA")
        expect(page).to have_text("Distance")
        expect(page).to have_text("42 miles")
        expect(page).to have_text("Travel time")
        expect(page).to have_text("30 minutes by public transport")
        expect(page).to have_text("15 minutes drive")
        expect(page).to have_text("45 minutes walk")
      end
    end
  end
end
