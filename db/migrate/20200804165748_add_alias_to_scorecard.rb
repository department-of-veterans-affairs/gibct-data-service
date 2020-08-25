class AddAliasToScorecard < ActiveRecord::Migration[5.2]
  def change
    add_column :scorecards, :alias, :string
  end
end
