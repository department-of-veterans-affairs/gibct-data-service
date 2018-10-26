class AddPhysicalAddressColumns < ActiveRecord::Migration
  def change
    %w[
      physical_address_1
      physical_address_2
      physical_address_3
      physical_city
      physical_state
      physical_zip
      physical_country
      dod_bah
    ].each do |attr|
      type =
        if attr == 'dod_bah'
          :integer
        else
          :string
        end

      add_column(:weams, attr, type)
      add_column(:institutions, attr, type)
    end
  end
end
