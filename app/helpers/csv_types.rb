# frozen_string_literal: true

module CsvTypes
  TABLES = [
    { klass: AccreditationAction, required?: true },
    { klass: AccreditationInstituteCampus, required?: true },
    { klass: AccreditationRecord, required?: true },
    { klass: ArfGiBill, required?: true },
    { klass: Complaint, required?: true },
    { klass: Crosswalk, required?: true },
    { klass: EightKey, required?: true },
    { klass: Hcm, required?: true },
    { klass: IpedsHd, required?: true },
    { klass: IpedsIcAy, required?: true },
    { klass: IpedsIcPy, required?: true },
    { klass: IpedsIc, required?: true },
    { klass: Mou, required?: true },
    { klass: Outcome, required?: true },
    { klass: P911Tf, required?: true },
    { klass: P911Yr, required?: true },
    { klass: Scorecard, required?: true },
    { klass: Sec702School, required?: true },
    { klass: Sec702, required?: true },
    { klass: Settlement, required?: true },
    { klass: Sva, required?: true },
    { klass: Vsoc, required?: true },
    { klass: Weam, required?: true },
    { klass: CalculatorConstant, required?: true },
    { klass: IpedsCipCode, required?: true },
    { klass: StemCipCode, required?: true },
    { klass: YellowRibbonProgramSource, required?: true },
    { klass: SchoolClosure, required?: true },
    { klass: Sec109ClosedSchool, required?: true },
    { klass: Program, required?: false }
  ].freeze

  def self.required_table_names
    TABLES.select { |table| table[:required?] }.map { |table| table[:klass].name }
  end

  def self.all_tables
    TABLES.map { |table| table[:klass] }
  end
end
