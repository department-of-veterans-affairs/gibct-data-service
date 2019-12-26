CSV_TYPES_TABLES = [
  { klass: AccreditationAction, required?: true, has_api?: false },
  { klass: AccreditationInstituteCampus, required?: true, has_api?: false },
  { klass: AccreditationRecord, required?: true, has_api?: false },
  { klass: ArfGiBill, required?: true, has_api?: false },
  { klass: Complaint, required?: true, has_api?: false },
  { klass: Crosswalk, required?: true, has_api?: false },
  { klass: EightKey, required?: true, has_api?: false },
  { klass: Hcm, required?: true, has_api?: false },
  { klass: IpedsHd, required?: true, has_api?: false },
  { klass: IpedsIcAy, required?: true, has_api?: false },
  { klass: IpedsIcPy, required?: true, has_api?: false },
  { klass: IpedsIc, required?: true, has_api?: false },
  { klass: Mou, required?: true, has_api?: false },
  { klass: Outcome, required?: true, has_api?: false },
  { klass: P911Tf, required?: true, has_api?: false },
  { klass: P911Yr, required?: true, has_api?: false },
  { klass: Scorecard, required?: true, has_api?: true },
  { klass: Sec702School, required?: true, has_api?: false },
  { klass: Sec702, required?: true, has_api?: false },
  { klass: Settlement, required?: true, has_api?: false },
  { klass: Sva, required?: true, has_api?: false },
  { klass: Vsoc, required?: true, has_api?: false },
  { klass: Weam, required?: true, has_api?: false },
  { klass: CalculatorConstant, required?: false, has_api?: false },
  { klass: IpedsCipCode, required?: true, has_api?: false },
  { klass: StemCipCode, required?: true, has_api?: false },
  { klass: YellowRibbonProgramSource, required?: true, has_api?: false },
  { klass: SchoolClosure, required?: true, has_api?: false },
  { klass: Sec109ClosedSchool, required?: true, has_api?: false },
  { klass: Program, required?: false, has_api?: false },
  { klass: SchoolCertifyingOfficial, required?: false, has_api?: false},
  { klass: EduProgram, required?: false, has_api?: false }
].freeze

CSV_TYPES_REQUIRED_TABLE_NAMES = CSV_TYPES_TABLES.select { |table| table[:required?] }.map { |table| table[:klass].name }
CSV_TYPES_HAS_API_TABLE_NAMES = CSV_TYPES_TABLES.select { |table| table[:has_api?] }.map { |table| table[:klass].name }
CSV_TYPES_ALL_TABLES = CSV_TYPES_TABLES.map { |table| table[:klass] }
