class CreateYellowRibbonDegreeLevelTranslations < ActiveRecord::Migration[7.1]
  def change
    create_table :yellow_ribbon_degree_level_translations do |t|
      t.string :raw_degree_level, null: false
      t.string :translations, null: false, array: true, default: []

      t.timestamps
    end

    add_index :yellow_ribbon_degree_level_translations, :raw_degree_level
  end
end
