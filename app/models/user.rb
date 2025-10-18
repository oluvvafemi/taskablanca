class User < ApplicationRecord
  belongs_to :organization

  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships

  has_many :task_assignments, dependent: :destroy
  has_many :tasks, through: :task_assignments

  validates :name, presence: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true
end
