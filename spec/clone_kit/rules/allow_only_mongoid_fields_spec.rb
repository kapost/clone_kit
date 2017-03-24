require "spec_helper"
require "clone_kit/rules/allow_only_mongoid_fields"

RSpec.describe CloneKit::Rules::AllowOnlyMongoidFields do
  subject { described_class.new(ExampleDoc) }

  let(:attributes) do
    {
      "another_embedded_example_doc" => { "extra_color" => "pink", "color" => "#c1c1c1" },
      "name" => "hubbub",
      "icon" => "toast",
      "background" => "#c0c0c0",
      "enabled" => true,
      "extra_attribute" => "STOP"
    }
  end

  describe "#fix" do
    it "deletes undefined field attributes" do
      subject.fix(nil, attributes)
      expect(attributes).to eql(
        "another_embedded_example_doc" => { "color" => "#c1c1c1" },
        "name" => "hubbub",
        "icon" => "toast",
        "enabled" => true
      )
    end

    context "attributes are symbols" do
      let(:attributes) do
        {
          another_embedded_example_doc: { extra_color: "pink", color: "#c1c1c1" },
          name: "hubbub",
          icon: "toast",
          background: "#c0c0c0",
          enabled: true,
          extra_attribute: "STOP"
        }
      end

      it "strips all attributes" do
        subject.fix(nil, attributes)
        expect(attributes).to eql({})
      end
    end
  end
end
