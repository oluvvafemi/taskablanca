class RemoveOrganizationIdFromUsersAndCreateOrganizationMemberships < ActiveRecord::Migration[8.0]
  def change
    remove_reference :users, :organization, foreign_key: true, index: true

    create_table :organization_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.integer :role, default: 0, null: false

      t.timestamps
    end

    add_index :organization_memberships, [ :user_id, :organization_id ], unique: true, name: 'index_org_memberships_on_user_and_org'
  end
end
