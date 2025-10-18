class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :tasks, through: :projects

  validates :name, presence: true, uniqueness: true
end
