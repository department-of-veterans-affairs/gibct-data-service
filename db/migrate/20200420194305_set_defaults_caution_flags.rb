class SetDefaultsCautionFlags < ActiveRecord::Migration[5.2]
  def up
    change_column_default :caution_flags,:title,'School engaged in misleading, deceptive, or erroneous practices'
    change_column_default :caution_flags, :description,'VA has found that this school engaged in misleading, deceptive, or erroneous advertising, sales, or enrollment practices, and has taken action against it.'
  end

  def down
    change_column_default :caution_flags,:title,nil
    change_column_default :caution_flags, :description,nil
  end
end
