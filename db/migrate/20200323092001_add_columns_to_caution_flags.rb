class AddColumnsToCautionFlags < ActiveRecord::Migration[5.2]
  def change
    add_column :caution_flags, :title, :string
    add_column :caution_flags, :description, :string
    add_column :caution_flags, :link_text, :string
    add_column :caution_flags, :link_url, :string
  end
end
