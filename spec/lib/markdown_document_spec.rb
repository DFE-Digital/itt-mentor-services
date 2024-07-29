require "rails_helper"

RSpec.describe MarkdownDocument do
  describe ".from_file" do
    subject(:from_file) { described_class.from_file("spec/fixtures/files/example.md") }

    it "returns a new instance of MarkdownDocument" do
      expect(from_file).to be_a(described_class)
    end

    it "is equal to an instance of MarkdownDocument initiated with the file content" do
      expect(from_file).to eq(described_class.new(file_fixture("example.md").read))
    end
  end

  describe ".from_directory" do
    subject(:from_directory) { described_class.from_directory("spec/fixtures/files") }

    it "returns an array of MarkdownDocument instances" do
      expect(from_directory).to all(be_a(described_class))
    end

    it "is equal to an array of instances of MarkdownDocument initiated with the file contents" do
      expect(from_directory).to eq([
        described_class.new(file_fixture("example.md").read),
        described_class.new(file_fixture("example_without_front_matter.md").read),
      ])
    end
  end

  describe "#raw_content" do
    context "when the markdown document does not contain front matter" do
      subject(:markdown_document_without_front_matter) { described_class.new(file_fixture("example_without_front_matter.md").read) }

      it "returns raw content of the markdown document" do
        expect(markdown_document_without_front_matter.raw_content).to eq(file_fixture("example_without_front_matter.md").read)
      end
    end

    context "when the markdown document contains front matter" do
      subject(:markdown_document) { described_class.new(file_fixture("example.md").read) }

      it "returns raw content of the markdown document" do
        expect(markdown_document.raw_content).to eq(file_fixture("example.md").read)
      end
    end
  end

  describe "#front_matter" do
    context "when the markdown document does not contain front matter" do
      subject(:markdown_document_without_front_matter) { described_class.new(file_fixture("example_without_front_matter.md").read) }

      it "returns the front matter as a hash with implicitly type-casted attributes" do
        expect(markdown_document_without_front_matter.front_matter).to be_nil
      end
    end

    context "when the markdown document contains front matter" do
      subject(:markdown_document) { described_class.new(file_fixture("example.md").read) }

      it "returns the front matter as a hash with implicitly type-casted attributes" do
        expect(markdown_document.front_matter).to eq({
          "string" => "string",
          "date" => Date.new(1970, 1, 1),
          "boolean" => true,
        })
      end
    end
  end

  describe "#content" do
    context "when the markdown document does not contain front matter" do
      subject(:markdown_document_without_front_matter) { described_class.new(file_fixture("example_without_front_matter.md").read) }

      it "returns the content of the markdown document" do
        expect(markdown_document_without_front_matter.content).to eq("# Example document without front matter\n\nThis is an example document. It contains some text without any front matter.\n")
      end
    end

    context "when the markdown document contains front matter" do
      subject(:markdown_document) { described_class.new(file_fixture("example.md").read) }

      it "returns the content of the markdown document without the front matter details" do
        expect(markdown_document.content).to eq("# Example document\n\nThis is an example document. It contains some text and front matter.\n")
      end
    end
  end
end
