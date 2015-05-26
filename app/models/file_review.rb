class FileReview < ActiveRecord::Base
  belongs_to :build
  has_many :violations, dependent: :destroy

  validates :build, presence: :true

  def completed?
    completed_at?
  end

  def running?
    !completed?
  end
end
