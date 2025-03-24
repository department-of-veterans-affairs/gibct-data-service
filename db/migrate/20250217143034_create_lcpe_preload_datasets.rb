class CreateLcpePreloadDatasets < ActiveRecord::Migration[7.1]
  def change
    create_table :lcpe_preload_datasets do |t|
      t.text :body
      t.string :subject_class

      t.timestamps
    end
  end
end
