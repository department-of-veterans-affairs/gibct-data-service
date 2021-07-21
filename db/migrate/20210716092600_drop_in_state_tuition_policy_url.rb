class DropInStateTuitionPolicyUrl < ActiveRecord::Migration[6.0]
  def change
    drop_table :in_state_tuition_policy_urls
  end
end
