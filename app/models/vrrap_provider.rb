class VrrapProvider < ImportableRecord
  CSV_CONVERTER_INFO = {
      'schoolname' => { column: :school_name, converter: FacilityCodeConverter },
      'facilitycode' => { column: :facility_code, converter: BaseConverter },
      'programs' => { column: :programs, converter: BaseConverter },
      'vaco_approved/disapproved' => { column: :vaco, converter: BaseConverter },
      'address' => { column: :address, converter: BaseConverter },
  }

  validates :facility_code, :vaco, presence: true

end