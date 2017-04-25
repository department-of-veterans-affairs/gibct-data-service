class AddPopulateAndIndexUuidOnVersions < ActiveRecord::Migration
  def up
    add_column :versions, :uuid, :binary, limit: 16

    Version.all.each do |version|
      version.generate_uuid
      version.save
    end

    add_index :versions, :uuid, unique: true
    change_column :versions, :uuid, :binary, limit: 16, null: false, unique: true
  end

  def down
    remove_column :versions, :uuid
  end
end
