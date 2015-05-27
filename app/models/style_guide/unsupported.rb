# Returns empty set of violations.
module StyleGuide
  class Unsupported < Base
    def file_review(_)
      ExcludedFileReview.new
    end
  end
end
