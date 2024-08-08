require "rails_helper"

RSpec.describe ApplicationForm do
  describe "#persist" do
    it "returns true" do
      expect(described_class.new.persist).to be(true)
    end
  end

  describe "#save" do
    context "when the form is valid" do
      it "returns true" do
        expect(described_class.new.save).to be(true)
      end
    end

    context "when the form is invalid" do
      before do
        invalid_form = Class.new(ApplicationForm) do
          attr_accessor :name

          validates :name, presence: true
        end

        stub_const("InvalidForm", invalid_form)
      end

      it "returns false" do
        expect(InvalidForm.new(name: nil).save).to be(false)
      end
    end
  end

  describe "#save!" do
    context "when the form is valid" do
      it "returns true" do
        expect(described_class.new.save!).to be(true)
      end
    end

    context "when the form is invalid" do
      before do
        invalid_form = Class.new(ApplicationForm) do
          attr_accessor :name

          validates :name, presence: true
        end

        stub_const("InvalidForm", invalid_form)
      end

      it "raises an error" do
        expect { InvalidForm.new(name: nil).save! }.to raise_error(ActiveModel::ValidationError, "Validation failed: Name can't be blank")
      end
    end
  end

  describe ".date_attribute" do
    subject(:example_form) { ExampleForm.new }

    before do
      example_form_class = Class.new(ApplicationForm) do
        date_attribute :date_of_birth
      end

      stub_const("ExampleForm", example_form_class)
    end

    it "adds getters and setters for the attribute suffixed with (1i), (2i), and (3i)" do
      example_form.public_send("date_of_birth(1i)=", 2024)
      example_form.public_send("date_of_birth(2i)=", 5)
      example_form.public_send("date_of_birth(3i)=", 2)

      expect(example_form.public_send("date_of_birth(1i)")).to eq(2024)
      expect(example_form.public_send("date_of_birth(2i)")).to eq(5)
      expect(example_form.public_send("date_of_birth(3i)")).to eq(2)
    end

    it "aliases the (1i), (2i), and (3i) suffixed attribute accessors to year, month, and day, respectively" do
      example_form.public_send("date_of_birth(1i)=", 2024)
      example_form.public_send("date_of_birth(2i)=", 5)
      example_form.public_send("date_of_birth(3i)=", 2)

      expect(example_form.date_of_birth_year).to eq(2024)
      expect(example_form.date_of_birth_month).to eq(5)
      expect(example_form.date_of_birth_day).to eq(2)

      example_form.public_send("date_of_birth_year=", 2025)
      example_form.public_send("date_of_birth_month=", 6)
      example_form.public_send("date_of_birth_day=", 3)

      expect(example_form.public_send("date_of_birth(1i)")).to eq(2025)
      expect(example_form.public_send("date_of_birth(2i)")).to eq(6)
      expect(example_form.public_send("date_of_birth(3i)")).to eq(3)
    end

    it "adds getter and setter methods to set and read all fields as Date objects" do
      example_form.date_of_birth_year = 2024
      example_form.date_of_birth_month = 5
      example_form.date_of_birth_day = 2

      expect(example_form.date_of_birth).to eq(Date.new(2024, 5, 2))

      example_form.date_of_birth = Date.new(2025, 6, 3)

      expect(example_form.date_of_birth_year).to eq(2025)
      expect(example_form.date_of_birth_month).to eq(6)
      expect(example_form.date_of_birth_day).to eq(3)
    end

    describe "date attribute setter" do
      it "casts strings into dates" do
        example_form.date_of_birth = "2024-05-02"

        expect(example_form.date_of_birth).to eq(Date.new(2024, 5, 2))
      end

      it "casts dates into dates" do
        example_form.date_of_birth = Date.new(2024, 5, 2)

        expect(example_form.date_of_birth).to eq(Date.new(2024, 5, 2))
      end

      it "casts times into dates" do
        example_form.date_of_birth = Time.new(2024, 5, 2, 12, 0, 0, 0)

        expect(example_form.date_of_birth).to eq(Date.new(2024, 5, 2))
      end

      it "doesn't cast other values" do
        expect { example_form.date_of_birth = 123 }.to raise_error(ArgumentError)
        expect { example_form.date_of_birth = 123.4 }.to raise_error(ArgumentError)
        expect { example_form.date_of_birth = true }.to raise_error(ArgumentError)
        expect { example_form.date_of_birth = false }.to raise_error(ArgumentError)
      end
    end

    describe "date attribute getter" do
      it "composes the individual date components into a date object" do
        example_form.date_of_birth_year = 2024
        example_form.date_of_birth_month = 5
        example_form.date_of_birth_day = 2

        expect(example_form.date_of_birth).to eq(Date.new(2024, 5, 2))
      end

      it "returns DateAttributes::IncompleteDate object if any of the date components are missing" do
        example_form.date_of_birth_year = 2024
        example_form.date_of_birth_month = 5

        expect(example_form.date_of_birth).to eq(DateAttributes::IncompleteDate.new(2024, 5, nil))
      end
    end
  end
end
