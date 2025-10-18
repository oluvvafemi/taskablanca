class Project < ApplicationRecord
  belongs_to :organization

  has_many :tasks, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships

  validates :title, presence: true, uniqueness: { scope: :organization_id }
end
