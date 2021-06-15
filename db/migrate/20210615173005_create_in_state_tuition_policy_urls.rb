class CreateInStateTuitionPolicyUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :in_state_tuition_policy_urls do |t|
      t.string :facility_code
      t.string :in_state_tuition_information

      t.timestamps
    end
  end
end
