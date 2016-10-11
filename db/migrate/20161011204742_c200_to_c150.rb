class C200ToC150 < ActiveRecord::Migration
  def change
    rename_column :scorecards, :c200_l4_pooled_supp, :c150_l4_pooled_supp
  end
end
