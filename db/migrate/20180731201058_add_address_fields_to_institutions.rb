class AddAddressFieldsToInstitutions < ActiveRecord::Migration[4.2]
  def change
    add_column(:institutions, :address_1, :string)
    add_column(:institutions, :address_2, :string)
    add_column(:institutions, :address_3, :string)
  end
end
