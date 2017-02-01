###############################################################################
## GibctInstitutionTYpe
## The model used when pushing data to the GIBCT database. This is the
## institution types table, and once the connection is set - all operations are
## carried out on the GIBCT DB.
###############################################################################
class GibctInstitutionType < ActiveRecord::Base
  include Standardizable

  self.table_name = 'institution_types'

  has_many :institutions, inverse_of: :institution_type

  validates :name, uniqueness: true, presence: true
  override_setters :name

  def self.set_connection(config)
    establish_connection(YAML.load_file(config)[Rails.env])
  end
end
