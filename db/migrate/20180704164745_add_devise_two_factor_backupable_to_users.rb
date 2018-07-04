class AddDeviseTwoFactorBackupableToUsers < ActiveRecord::Migration[5.2]
  def change
    # Change type from :string to :text if using MySQL database
    add_column :users, :otp_backup_codes, :string, array: true
  end
end

