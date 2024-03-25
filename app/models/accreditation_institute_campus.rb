# frozen_string_literal: true

class AccreditationInstituteCampus < ImportableRecord
  self.table_name = 'accreditation_institute_campuses'

  has_many(:accreditation_records, primary_key: :dapip_id, foreign_key: 'dapip_id',
                                   inverse_of: :accreditation_institute_campus,
                                   dependent: :nullify)
  has_many(:accreditation_actions, primary_key: :dapip_id, foreign_key: 'dapip_id',
                                   inverse_of: :accreditation_institute_campus,
                                   dependent: :nullify)

  CSV_CONVERTER_INFO = {
    'dapipid' => { column: :dapip_id, converter: Converters::NumberConverter },
    'opeid' => { column: :ope, converter: Converters::OpeConverter },
    'locationname' => { column: :location_name, converter: Converters::InstitutionConverter },
    'parentname' => { column: :parent_name, converter: Converters::InstitutionConverter },
    'parentdapipid' => { column: :parent_dapip_id, converter: Converters::NumberConverter },
    'locationtype' => { column: :location_type, converter: Converters::BaseConverter },
    'address' => { column: :address, converter: Converters::BaseConverter },
    'generalphone' => { column: :general_phone, converter: Converters::BaseConverter },
    'adminname' => { column: :admin_name, converter: Converters::BaseConverter },
    'adminphone' => { column: :admin_phone, converter: Converters::BaseConverter },
    'adminemail' => { column: :admin_email, converter: Converters::BaseConverter },
    'fax' => { column: :fax, converter: Converters::BaseConverter },
    'updatedate' => { column: :update_date, converter: Converters::DateConverter }
  }.freeze

  validates :dapip_id, presence: true

  after_initialize :set_ope6

  private

  def set_ope6
    self.ope6 = Converters::Ope6Converter.convert(ope)
  end
end
