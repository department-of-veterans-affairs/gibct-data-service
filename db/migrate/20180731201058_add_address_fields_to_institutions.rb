class AddAddressFieldsToInstitutions < ActiveRecord::Migration
  def change
    add_column(:institutions, :address_1, :string)
    add_column(:institutions, :address_2, :string)
    add_column(:institutions, :address_3, :string)
  end
end
