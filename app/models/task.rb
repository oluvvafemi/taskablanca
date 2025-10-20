class Task < ApplicationRecord
  belongs_to :project

  has_many :task_assignments, dependent: :destroy
  has_many :users, through: :task_assignments

  validates :title, presence: true
  validates :description, presence: true

  enum :status, %w[ todo in_progress done ].index_by(&:itself),
       validate: true, default: "todo"

  scope :search, ->(query) {
    return all if query.blank?

    where(
      "tasks.title ILIKE ? OR tasks.description ILIKE ?",
      "%#{query}%", "%#{query}%"
    )
  }
end
