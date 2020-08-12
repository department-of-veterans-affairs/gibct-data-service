class AddFlagDateToCautionFlags < ActiveRecord::Migration[5.2]
  def change
    add_column :caution_flags, :flag_date, :string
  end
end
