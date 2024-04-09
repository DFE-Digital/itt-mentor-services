require "rails_helper"

RSpec.describe Gias::CsvTransformer do
  subject(:output_file) { described_class.call(input_file) }

  let(:input_file_path) { "spec/fixtures/gias/gias_subset.csv" }
  let(:input_file) { File.open(input_file_path, "r") }

  it_behaves_like "a service object" do
    let(:params) { { 0 => input_file } }
  end

  it "transforms the GIAS CSV" do
    expected_output = File.read("spec/fixtures/gias/gias_subset_transformed.csv")
    actual_output = output_file.read
    expect(actual_output).to eq(expected_output)
  end

  it "filters out schools which are Closed or not in England" do
    output_csv = CSV.read(output_file, headers: true)
    urns = output_csv.values_at("URN").flatten
    expect(urns).to eq %w[100000 137666 124087]
  end
end
