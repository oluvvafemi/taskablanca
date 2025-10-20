class Project < ApplicationRecord
  belongs_to :organization

  has_many :tasks, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships

  validates :title, presence: true, uniqueness: { scope: :organization_id }

  scope :search, ->(query) {
    return all if query.blank?

    where(
      "projects.title ILIKE ? OR projects.description ILIKE ?",
      "%#{query}%", "%#{query}%"
    )
  }
end
