class CreateVersionPublicExports < ActiveRecord::Migration[7.1]
  def change
    create_table :version_public_exports do |t|
      t.bigint :version_id
      t.string :file_type
      t.binary :data

      t.timestamps
    end
  end
end
