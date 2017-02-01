###############################################################################
## GibctInstitution
## The model used when pushing data to the GIBCT database. This is the
## institutions table, and once the connection is set - all operations are
## carried out on the GIBCT DB.
###############################################################################
class GibctInstitution < ActiveRecord::Base
  self.table_name = 'institutions'

  belongs_to :institution_type, inverse_of: :institutions

  validates :facility_code, uniqueness: true, presence: true
  validates :institution, presence: true
  validates :country, presence: true
  validates :institution_type_id, presence: true

  def self.set_connection(config)
    establish_connection(YAML.load_file(config)[Rails.env])
  end
end
