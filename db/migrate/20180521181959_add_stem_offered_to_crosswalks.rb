class AddStemOfferedToCrosswalks < ActiveRecord::Migration
  def change
    add_column :crosswalks, :stem_offered, :boolean
  end
end
