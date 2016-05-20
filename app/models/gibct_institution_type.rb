class GibctInstitutionType < ActiveRecord::Base  
  include Standardizable

  establish_connection(YAML.load_file("./config/gibct_database.yml")[Rails.env])
  self.table_name = 'institution_types'

  has_many :institutions, inverse_of: :institution_type

  validates :name, uniqueness: true, presence: true
  override_setters :name
end