class OrganizationMembership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { member: 0, admin: 1, owner: 2 }, default: :member

  validates :user_id, uniqueness: { scope: :organization_id, message: "is already a member of this organization" }
end
