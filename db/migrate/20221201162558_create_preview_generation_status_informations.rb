class CreatePreviewGenerationStatusInformations < ActiveRecord::Migration[6.1]
  def change
    create_table :preview_generation_status_informations do |t|
      t.string :current_progress
    end
  end
end
