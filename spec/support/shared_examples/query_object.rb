RSpec.shared_examples "a query object" do |query_model, filter_method|
  describe "#filter_by" do
    let(:model) { described_class }
    let!(:scope) { create_list(query_model.to_s.underscore.to_sym, 5) }

    context "when the filter given has no value" do
      it "does not affect the scope" do
        expect(
          described_class.new.filter_by({ filter_method => nil }),
        ).to match(scope)
      end
    end

    context "when the filter given is not a filter in the query object" do
      it "does not affect the scope" do
        expect(
          described_class.new.filter_by({ random_method: nil }),
        ).to match(scope)
      end
    end
  end
end
