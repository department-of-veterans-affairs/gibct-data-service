class GibctInstitution < ActiveRecord::Base
  establish_connection(YAML.load_file("./config/gibct_database.yml")[Rails.env])
  self.table_name = 'institutions'

  belongs_to :institution_type, inverse_of: :institutions

  validates :facility_code, uniqueness: true, presence: true
  validates :institution, presence: true
  validates :country, presence: true
  validates :institution_type_id, presence: true
end