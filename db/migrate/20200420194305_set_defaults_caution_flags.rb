class SetDefaultsCautionFlags < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      change_table :caution_flags do |t|
        t.change :title, :string, default: 'School engaged in misleading, deceptive, or erroneous practices'
        t.change :description, :string, default: 'VA has found that this school engaged in misleading, deceptive, or erroneous advertising, sales, or enrollment practices, and has taken action against it.'
      end
    end
  end

  def down
    safety_assured do
      change_table :caution_flags do |t|
        t.change :title, :string, default: nil
        t.change :description, :string, default: nil
      end
    end
  end
end
