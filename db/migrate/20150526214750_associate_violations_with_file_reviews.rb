class AssociateViolationsWithFileReviews < ActiveRecord::Migration
  class Violation < ActiveRecord::Base
    belongs_to :file_review
  end
  class FileReview < ActiveRecord::Base; end

  def up
    add_column :file_reviews, :filename, :string, null: false
    add_column :violations, :file_review_id, :integer

    associate_violations_with_file_reviews

    change_column_null :violations, :file_review_id, false
    remove_column :violations, :build_id
    remove_column :violations, :filename

    add_index :violations, :file_review_id
    add_foreign_key :violations, :file_reviews, on_delete: :cascade
  end

  def down
    add_column :violations, :build_id, :integer
    add_column :violations, :filename, :string

    associate_violations_with_builds

    change_column_null :violations, :build_id, false
    change_column_null :violations, :filename, false
    remove_column :violations, :file_review_id
    remove_column :file_reviews, :filename, :string, null: false

    truncate :file_reviews
  end

  private

  def associate_violations_with_file_reviews
    Violation.find_each do |violation|
      file_review = FileReview.find_or_create_by!(
        build_id: violation.build_id,
        filename: violation.filename,
        completed_at: Time.current
      )
      violation.update!(file_review_id: file_review.id)
    end
  end

  def associate_violations_with_builds
    Violation.includes(:file_review).find_each do |violation|
      violation.update!(
        build_id: violation.file_review.build_id,
        filename: violation.file_review.filename,
      )
    end
  end
end
