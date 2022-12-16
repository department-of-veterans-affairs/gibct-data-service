class AddUngeocodableToInstitution < ActiveRecord::Migration[6.1]
  def change
    add_column :institutions, :ungeocodable, :boolean, default: false
    add_column :institutions_archives, :ungeocodable, :boolean
  end
end
