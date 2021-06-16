# frozen_string_literal: true

module InstitutionBuilder
  class InStateTuitionPolicyUrlBuilder
    extend Common

    def self.add_in_state_tuition_policy_url(version_id)
      str = <<-SQL
        institutions.facility_code = in_state_tuition_policy_urls.facility_code
      SQL
      add_columns_for_update(version_id, InStateTuitionPolicyUrl, str)
    end
  end
end
