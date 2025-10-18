class User < ApplicationRecord
  belongs_to :organization

  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships

  has_many :task_assignments, dependent: :destroy
  has_many :tasks, through: :task_assignments

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
