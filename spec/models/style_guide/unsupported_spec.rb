require "attr_extras"
require "spec_helper"
require "app/models/style_guide/base"
require "app/models/style_guide/unsupported"
require "app/models/excluded_file_review"

describe StyleGuide::Unsupported do
  describe "#file_review" do
    it "returns file review without violations" do
      style_guide = StyleGuide::Unsupported.new({}, nil)

      expect(style_guide.file_review("file.txt").violations).to eq []
    end
  end
end
