class UpdateUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :email, :email_address
    add_column :users, :password_digest, :string, null: false
  end
end
