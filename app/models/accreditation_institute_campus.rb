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
    'dapipid' => { column: :dapip_id, converter: NumberConverter },
    'opeid' => { column: :ope, converter: OpeConverter },
    'locationname' => { column: :location_name, converter: InstitutionConverter },
    'parentname' => { column: :parent_name, converter: InstitutionConverter },
    'parentdapipid' => { column: :parent_dapip_id, converter: NumberConverter },
    'locationtype' => { column: :location_type, converter: BaseConverter },
    'address' => { column: :address, converter: BaseConverter },
    'generalphone' => { column: :general_phone, converter: BaseConverter },
    'adminname' => { column: :admin_name, converter: BaseConverter },
    'adminphone' => { column: :admin_phone, converter: BaseConverter },
    'adminemail' => { column: :admin_email, converter: BaseConverter },
    'fax' => { column: :fax, converter: BaseConverter },
    'updatedate' => { column: :update_date, converter: DateConverter }
  }.freeze

  validates :dapip_id, presence: true

  after_initialize :set_ope6

  private

  def set_ope6
    self.ope6 = Ope6Converter.convert(ope)
  end
end
