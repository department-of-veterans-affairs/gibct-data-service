class AddBadAddressInstitution < ActiveRecord::Migration[6.1]
  def change
  	add_column :institutions, :bad_address, :boolean, default: false
  end
end
