class AccreditationInstituteCampus < ActiveRecord::Base
  self.table_name = 'accreditation_institute_campuses'

  include CsvHelper

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
end
