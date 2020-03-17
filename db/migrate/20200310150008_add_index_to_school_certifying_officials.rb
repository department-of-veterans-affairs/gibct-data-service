class AddIndexToSchoolCertifyingOfficials < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :school_certifying_officials, :facility_code, algorithm: :concurrently
  end
end
