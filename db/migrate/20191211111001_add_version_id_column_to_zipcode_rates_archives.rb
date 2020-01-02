class AddVersionIdColumnToZipcodeRatesArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :zipcode_rates_archives, :version_id, :integer
  end
end