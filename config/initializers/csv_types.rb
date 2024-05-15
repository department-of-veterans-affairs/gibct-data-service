Rails.application.config.to_prepare do
  CSV_TYPES_TABLES = [
    { klass: AccreditationAction, required?: true, has_api?: true, no_api_key?: true },
    { klass: AccreditationInstituteCampus, required?: true, has_api?: true, no_api_key?: true },
    { klass: AccreditationRecord, required?: true, has_api?: true, no_api_key?: true },
    { klass: ArfGiBill, required?: true },
    { klass: CipCode, required?: false, no_upload?: true },
    { klass: Complaint, required?: true },
    { klass: Crosswalk, required?: true },
    { klass: EightKey, required?: true },
    { klass: Hcm, required?: true, has_api?: true, no_api_key?: true },
    { klass: IpedsHd, required?: true, has_api?: true, no_api_key?: true },
    { klass: IpedsIcAy, required?: true, has_api?: true, no_api_key?: true },
    { klass: IpedsIcPy, required?: true, has_api?: true, no_api_key?: true },
    { klass: IpedsIc, required?: true, has_api?: true, no_api_key?: true },
    { klass: Mou, required?: true },
    { klass: Outcome, required?: true },
    { klass: Scorecard, required?: true, has_api?: true },
    { klass: ScorecardDegreeProgram, required?: false, has_api?: true },
    { klass: Sec702, required?: true },
    { klass: Sva, required?: true },
    { klass: Vsoc, required?: true },
    { klass: Weam, required?: true },
    { klass: CalculatorConstant, required?: false },
    { klass: IpedsCipCode, required?: true },
    { klass: StemCipCode, required?: true },
    { klass: YellowRibbonProgramSource, required?: true },
    { klass: Sec109ClosedSchool, required?: true },
    { klass: Program, required?: false },
    { klass: SchoolCertifyingOfficial, required?: false},
    { klass: EduProgram, required?: false },
    { klass: Sec103, required?: false },
    { klass: VaCautionFlag, required?: false },
    { klass: Post911Stat, required?: false },
    { klass: VrrapProvider, required?: false, no_upload?: true },
    { klass: InstitutionOwner, required?: false },
    { klass: InstitutionSchoolRating, required?: false },
    { klass: Section1015, required?: false }
  ].freeze

  CSV_TYPES_HAS_API_TABLE_NAMES = CSV_TYPES_TABLES.select { |table| table[:has_api?] }.map { |table| table[:klass].name }.freeze
  CSV_TYPES_NO_API_KEY_TABLE_NAMES = CSV_TYPES_TABLES.select { |table| table[:no_api_key?] }.map { |table| table[:klass].name }.freeze
  CSV_TYPES_NO_UPLOAD_TABLE_NAMES = CSV_TYPES_TABLES.select { |table| table[:no_upload?] }.map { |table| table[:klass].name }.freeze
  CSV_TYPES_ALL_TABLES_CLASSES = CSV_TYPES_TABLES.map { |table| table[:klass] }.freeze
end
