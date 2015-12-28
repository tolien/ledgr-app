class AddUnconfirmedEmailToUsers < ActiveRecord::Migration
  def up
      add_column :users, :unconfirmed_email, :string
      User.reset_column_information
  end
  
  def down
      remove_columns :users, :unconfirmed_email
      User.reset_column_information
  end
end
