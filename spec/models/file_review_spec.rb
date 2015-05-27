require "rails_helper"

describe FileReview do
  describe "associations" do
    it { should belong_to :build }
  end

  describe "#build_violation" do
    context "when line has been changed" do
      it "builds a violations" do
        line = double("Line", changed?: true, patch_position: 121)
        file_review = FileReview.new
        expected_violation = Violation.new(
          patch_position: 121,
          line_number: 1,
          messages: ["hello"]
        )

        file_review.build_violation(line, 1, "hello")
        violation = file_review.violations.first

        expect(file_review.violations.size).to eq 1
        expect(violation.patch_position).to eq expected_violation.patch_position
        expect(violation.line_number).to eq expected_violation.line_number
        expect(violation.messages).to eq expected_violation.messages
      end
    end

    context "when line has not been changed" do
      it "does not build a violations" do
        line = double("Line", changed?: false)
        file_review = FileReview.new

        file_review.build_violation(line, 1, "hello")

        expect(file_review.violations).to be_empty
      end
    end
  end

  describe "#complete" do
    it "marks it as completed" do
      file_review = FileReview.new

      file_review.complete

      expect(file_review).to be_completed
    end
  end

  describe "#completed?" do
    it "returns true when completed_at is set" do
      file_review = FileReview.new(completed_at: Time.zone.now)

      expect(file_review).to be_completed
    end

    it "returns false when completed_at is nil" do
      file_review = FileReview.new

      expect(file_review).not_to be_completed
    end
  end

  describe "#running?" do
    it "returns true when complete_at is set" do
      file_review = FileReview.new(completed_at: Time.zone.now)

      expect(file_review).not_to be_running
    end

    it "returns false when completed_at is nil" do
      file_review = FileReview.new(completed_at: nil)

      expect(file_review).to be_running
    end
  end
end
