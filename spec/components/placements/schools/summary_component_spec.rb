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

  context "when the school is open to hosting" do
    context "when the school does not have any placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "interested") }

      it "displays the school's hosting interest" do
        expect(page).to have_content("May offer placements")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placement_information")
      end

      it "displays the school's name" do
        expect(page).to have_content("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_content("School details")
        expect(page).to have_content("Phase")
        expect(page).to have_content("All-through")
        expect(page).to have_content("Age range")
        expect(page).to have_content("5 to 11")
        expect(page).to have_content("Establishment group")
        expect(page).to have_content("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_content("Placement information")
        expect(page).to have_content("Last offered")
        expect(page).to have_content("This school has not previously hosted placements")
        expect(page).to have_content("Contact")
        expect(page).to have_content("Placement Coordinator")
        expect(page).to have_content("placement_coordinator@example.school")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_content("Getting there")
          expect(page).to have_content("Address")
          expect(page).to have_content("Magical Lane")
          expect(page).to have_content("London")
          expect(page).to have_content("SW1A 1AA")
          expect(page).to have_content("Distance")
          expect(page).to have_content("42 miles")
          expect(page).to have_content("Travel time")
          expect(page).to have_content("30 minutes by public transport")
          expect(page).to have_content("15 minutes drive")
          expect(page).to have_content("45 minutes walk")
        end
      end
    end

    context "when the school has unfilled placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "actively_looking") }

      let(:placements) { build_list(:placement, 1) }

      it "displays the school's hosting interest" do
        expect(page).to have_content("Placements available")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      end

      it "displays the school's name" do
        expect(page).to have_content("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_content("School details")
        expect(page).to have_content("Phase")
        expect(page).to have_content("All-through")
        expect(page).to have_content("Age range")
        expect(page).to have_content("5 to 11")
        expect(page).to have_content("Establishment group")
        expect(page).to have_content("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_content("Placement information")
        expect(page).to have_content("Unfilled placements")
        expect(page).to have_link("1 unfilled placement", href: "/providers/#{provider.id}/find/#{school.id}/placements")
        expect(page).to have_content("Hosting subjects")
        expect(page).to have_content("0 filled placements")
        expect(page).to have_content("Last offered")
        expect(page).to have_content("This school has not previously hosted placements")
        expect(page).to have_content("Contact")
        expect(page).to have_content("Placement Coordinator")
        expect(page).to have_content("placement_coordinator@example.school")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_content("Getting there")
          expect(page).to have_content("Address")
          expect(page).to have_content("Magical Lane")
          expect(page).to have_content("London")
          expect(page).to have_content("SW1A 1AA")
          expect(page).to have_content("Distance")
          expect(page).to have_content("42 miles")
          expect(page).to have_content("Travel time")
          expect(page).to have_content("30 minutes by public transport")
          expect(page).to have_content("15 minutes drive")
          expect(page).to have_content("45 minutes walk")
        end
      end
    end

    context "when the school has unfilled and filled placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "actively_looking") }
      let(:placements) { [build(:placement, provider:), build(:placement)] }

      it "displays the school's hosting interest" do
        expect(page).to have_content("Placements available")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      end

      it "displays the school's name" do
        expect(page).to have_content("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_content("School details")
        expect(page).to have_content("Phase")
        expect(page).to have_content("All-through")
        expect(page).to have_content("Age range")
        expect(page).to have_content("5 to 11")
        expect(page).to have_content("Establishment group")
        expect(page).to have_content("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_content("Placement information")
        expect(page).to have_content("Unfilled placements")
        expect(page).to have_link("1 unfilled placement", href: "/providers/#{provider.id}/find/#{school.id}/placements")
        expect(page).to have_content("Hosting subjects")
        expect(page).to have_content("1 filled placement")
        expect(page).to have_content("Last offered")
        expect(page).to have_content("This school has not previously hosted placements")
        expect(page).to have_content("Contact")
        expect(page).to have_content("Placement Coordinator")
        expect(page).to have_content("placement_coordinator@example.school")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_content("Getting there")
          expect(page).to have_content("Address")
          expect(page).to have_content("Magical Lane")
          expect(page).to have_content("London")
          expect(page).to have_content("SW1A 1AA")
          expect(page).to have_content("Distance")
          expect(page).to have_content("42 miles")
          expect(page).to have_content("Travel time")
          expect(page).to have_content("30 minutes by public transport")
          expect(page).to have_content("15 minutes drive")
          expect(page).to have_content("45 minutes walk")
        end
      end
    end

    context "when the school only has filled placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "actively_looking") }
      let(:placements) { build_list(:placement, 1, provider:) }

      it "displays the school's hosting interest" do
        expect(page).to have_content("No placements available")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placements")
      end

      it "displays the school's name" do
        expect(page).to have_content("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_content("School details")
        expect(page).to have_content("Phase")
        expect(page).to have_content("All-through")
        expect(page).to have_content("Age range")
        expect(page).to have_content("5 to 11")
        expect(page).to have_content("Establishment group")
        expect(page).to have_content("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_content("Placement information")
        expect(page).to have_content("Hosting subjects")
        expect(page).to have_content("1 filled placement")
        expect(page).to have_content("Last offered")
        expect(page).to have_content("This school has not previously hosted placements")
        expect(page).to have_content("Contact")
        expect(page).to have_content("Placement Coordinator")
        expect(page).to have_content("placement_coordinator@example.school")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_content("Getting there")
          expect(page).to have_content("Address")
          expect(page).to have_content("Magical Lane")
          expect(page).to have_content("London")
          expect(page).to have_content("SW1A 1AA")
          expect(page).to have_content("Distance")
          expect(page).to have_content("42 miles")
          expect(page).to have_content("Travel time")
          expect(page).to have_content("30 minutes by public transport")
          expect(page).to have_content("15 minutes drive")
          expect(page).to have_content("45 minutes walk")
        end
      end
    end

    context "when the school has previously hosted placements" do
      let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "interested") }
      let(:previous_academic_year) { Placements::AcademicYear.current.previous }
      let(:placements) { build_list(:placement, 1, academic_year: previous_academic_year, provider:) }

      it "displays the school's hosting interest" do
        expect(page).to have_content("May offer placements")
      end

      it "displays a link to the school's details page" do
        expect(page).to have_link("Hogwarts, London", href: "/providers/#{provider.id}/find/#{school.id}/placement_information")
      end

      it "displays the school's name" do
        expect(page).to have_content("Hogwarts")
      end

      it "displays the school's details", :aggregate_failures do
        expect(page).to have_content("School details")
        expect(page).to have_content("Phase")
        expect(page).to have_content("All-through")
        expect(page).to have_content("Age range")
        expect(page).to have_content("5 to 11")
        expect(page).to have_content("Establishment group")
        expect(page).to have_content("Local authority maintained schools")
      end

      it "displays placement information", :aggregate_failures do
        expect(page).to have_content("Placement information")
        expect(page).to have_content("Last offered")
        expect(page).to have_content("1 subject in #{previous_academic_year.name}")
        expect(page).to have_content("Contact")
        expect(page).to have_content("Placement Coordinator")
        expect(page).to have_content("placement_coordinator@example.school")
      end

      context "when location coordinates have been provided" do
        subject(:component) do
          described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
        end

        it "displays the getting there section", :aggregate_failures do
          expect(page).to have_content("Getting there")
          expect(page).to have_content("Address")
          expect(page).to have_content("Magical Lane")
          expect(page).to have_content("London")
          expect(page).to have_content("SW1A 1AA")
          expect(page).to have_content("Distance")
          expect(page).to have_content("42 miles")
          expect(page).to have_content("Travel time")
          expect(page).to have_content("30 minutes by public transport")
          expect(page).to have_content("15 minutes drive")
          expect(page).to have_content("45 minutes walk")
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
      expect(page).to have_content("Placement availability unknown")
    end

    it "displays the school's name" do
      expect(page).to have_content("Hogwarts")
    end

    it "displays the school's details", :aggregate_failures do
      expect(page).to have_content("School details")
      expect(page).to have_content("Phase")
      expect(page).to have_content("All-through")
      expect(page).to have_content("Age range")
      expect(page).to have_content("5 to 11")
      expect(page).to have_content("Establishment group")
      expect(page).to have_content("Local authority maintained schools")
    end

    it "displays placement information", :aggregate_failures do
      expect(page).to have_content("Placement information")
      expect(page).to have_content("Placement subjects")
      expect(page).to have_content("Not offering placements")
      expect(page).to have_content("Previous placements")
      expect(page).to have_content("This school has previously hosted placements")
    end
  end

  context "when the school is not open to hosting" do
    let(:hosting_interests) { build_list(:hosting_interest, 1, appetite: "not_open") }

    it "displays the school's hosting interest" do
      expect(page).to have_content("Not offering placements")
    end

    it "displays the school's name" do
      expect(page).to have_content("Hogwarts")
    end

    it "displays the school's details", :aggregate_failures do
      expect(page).to have_content("School details")
      expect(page).to have_content("Phase")
      expect(page).to have_content("All-through")
      expect(page).to have_content("Age range")
      expect(page).to have_content("5 to 11")
      expect(page).to have_content("Establishment group")
      expect(page).to have_content("Local authority maintained schools")
    end

    it "displays placement information", :aggregate_failures do
      expect(page).to have_content("Placement information")
      expect(page).to have_content("Placement subjects")
      expect(page).to have_content("Not offering placements")
      expect(page).to have_content("Previous placements")
      expect(page).to have_content("This school has not previously hosted placements")
    end

    it "displays a message indicating the school doesn't want to be contacted" do
      expect(page).to have_content("This school does not wish to be contacted this academic year.")
    end

    context "when location coordinates have been provided" do
      subject(:component) do
        described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
      end

      it "does not display the getting there section" do
        expect(page).not_to have_content("Getting there")
      end
    end
  end

  context "when the school has not registered a hosting interest" do
    it "does not display a hosting interest" do
      expect(page).not_to have_content("Not hosting")
      expect(page).not_to have_content("Open to hosting")
      expect(page).not_to have_content("Already organised placements")
      expect(page).not_to have_content("Unfilled placements")
    end

    it "displays the school's name" do
      expect(page).to have_content("Hogwarts")
    end

    it "displays the school's details", :aggregate_failures do
      expect(page).to have_content("School details")
      expect(page).to have_content("Phase")
      expect(page).to have_content("All-through")
      expect(page).to have_content("Age range")
      expect(page).to have_content("5 to 11")
      expect(page).to have_content("Establishment group")
      expect(page).to have_content("Local authority maintained schools")
    end

    it "displays placement information", :aggregate_failures do
      expect(page).to have_content("Placement availability unknown")
      expect(page).to have_content("Previous placements")
      expect(page).to have_content("This school has not previously hosted placements")
    end

    context "when location coordinates have been provided" do
      subject(:component) do
        described_class.new(school:, provider:, academic_year:, location_coordinates: "41.40338, 2.17403")
      end

      it "displays the getting there section", :aggregate_failures do
        expect(page).to have_content("Getting there")
        expect(page).to have_content("Address")
        expect(page).to have_content("Magical Lane")
        expect(page).to have_content("London")
        expect(page).to have_content("SW1A 1AA")
        expect(page).to have_content("Distance")
        expect(page).to have_content("42 miles")
        expect(page).to have_content("Travel time")
        expect(page).to have_content("30 minutes by public transport")
        expect(page).to have_content("15 minutes drive")
        expect(page).to have_content("45 minutes walk")
      end
    end
  end
end
