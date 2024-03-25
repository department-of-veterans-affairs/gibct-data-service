# frozen_string_literal: true

class IpedsIc < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[
    credit_for_mil_training vet_poc student_vet_grp_ipeds
    soc_member calendar online_all
  ].freeze

  # Note do not map the "integer" values to "boolean" values otherwise exports will put true/false instead of 1/0,
  # instead move them to dependent booleans before validation.
  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: Converters::CrossConverter },
    'peo1istr' => { column: :peo1istr, converter: Converters::NumberConverter },
    'peo2istr' => { column: :peo2istr, converter: Converters::NumberConverter },
    'peo3istr' => { column: :peo3istr, converter: Converters::NumberConverter },
    'peo4istr' => { column: :peo4istr, converter: Converters::NumberConverter },
    'peo5istr' => { column: :peo5istr, converter: Converters::NumberConverter },
    'peo6istr' => { column: :peo6istr, converter: Converters::NumberConverter },
    'cntlaffi' => { column: :cntlaffi, converter: Converters::NumberConverter },
    'pubprime' => { column: :pubprime, converter: Converters::NumberConverter },
    'pubsecon' => { column: :pubsecon, converter: Converters::NumberConverter },
    'relaffil' => { column: :relaffil, converter: Converters::NumberConverter },
    'level1' => { column: :level1, converter: Converters::NumberConverter },
    'level2' => { column: :level2, converter: Converters::NumberConverter },
    'level3' => { column: :level3, converter: Converters::NumberConverter },
    'level4' => { column: :level4, converter: Converters::NumberConverter },
    'level5' => { column: :level5, converter: Converters::NumberConverter },
    'level6' => { column: :level6, converter: Converters::NumberConverter },
    'level7' => { column: :level7, converter: Converters::NumberConverter },
    'level8' => { column: :level8, converter: Converters::NumberConverter },
    'level12' => { column: :level12, converter: Converters::NumberConverter },
    'level17' => { column: :level17, converter: Converters::NumberConverter },
    'level18' => { column: :level18, converter: Converters::NumberConverter },
    'level19' => { column: :level19, converter: Converters::NumberConverter },
    'openadmp' => { column: :openadmp, converter: Converters::NumberConverter },
    'credits1' => { column: :credits1, converter: Converters::NumberConverter },
    'credits2' => { column: :credits2, converter: Converters::NumberConverter },
    'credits3' => { column: :credits3, converter: Converters::NumberConverter },
    'credits4' => { column: :credits4, converter: Converters::NumberConverter },
    'slo5' => { column: :slo5, converter: Converters::NumberConverter },
    'slo51' => { column: :slo51, converter: Converters::NumberConverter },
    'slo52' => { column: :slo52, converter: Converters::NumberConverter },
    'slo53' => { column: :slo53, converter: Converters::NumberConverter },
    'slo6' => { column: :slo6, converter: Converters::NumberConverter },
    'slo7' => { column: :slo7, converter: Converters::NumberConverter },
    'slo8' => { column: :slo8, converter: Converters::NumberConverter },
    'slo81' => { column: :slo81, converter: Converters::NumberConverter },
    'slo82' => { column: :slo82, converter: Converters::NumberConverter },
    'slo83' => { column: :slo83, converter: Converters::NumberConverter },
    'slo9' => { column: :slo9, converter: Converters::NumberConverter },
    'yrscoll' => { column: :yrscoll, converter: Converters::NumberConverter },
    'stusrv1' => { column: :stusrv1, converter: Converters::NumberConverter },
    'stusrv2' => { column: :stusrv2, converter: Converters::NumberConverter },
    'stusrv3' => { column: :stusrv3, converter: Converters::NumberConverter },
    'stusrv4' => { column: :stusrv4, converter: Converters::NumberConverter },
    'stusrv8' => { column: :stusrv8, converter: Converters::NumberConverter },
    'stusrv9' => { column: :stusrv9, converter: Converters::NumberConverter },
    'libfac' => { column: :libfac, converter: Converters::NumberConverter },
    'athassoc' => { column: :athassoc, converter: Converters::NumberConverter },
    'assoc1' => { column: :assoc1, converter: Converters::NumberConverter },
    'assoc2' => { column: :assoc2, converter: Converters::NumberConverter },
    'assoc3' => { column: :assoc3, converter: Converters::BaseConverter },
    'assoc4' => { column: :assoc4, converter: Converters::NumberConverter },
    'assoc5' => { column: :assoc5, converter: Converters::NumberConverter },
    'assoc6' => { column: :assoc6, converter: Converters::NumberConverter },
    'sport1' => { column: :sport1, converter: Converters::NumberConverter },
    'confno1' => { column: :confno1, converter: Converters::NumberConverter },
    'sport2' => { column: :sport2, converter: Converters::NumberConverter },
    'confno2' => { column: :confno2, converter: Converters::NumberConverter },
    'sport3' => { column: :sport3, converter: Converters::NumberConverter },
    'confno3' => { column: :confno3, converter: Converters::NumberConverter },
    'sport4' => { column: :sport4, converter: Converters::NumberConverter },
    'confno4' => { column: :confno4, converter: Converters::NumberConverter },
    'calsys' => { column: :calsys, converter: Converters::NumberConverter },
    'xappfeeu' => { column: :xappfeeu, converter: Converters::BaseConverter },
    'applfeeu' => { column: :applfeeu, converter: Converters::NumberConverter },
    'xappfeeg' => { column: :xappfeeg, converter: Converters::BaseConverter },
    'applfeeg' => { column: :applfeeg, converter: Converters::NumberConverter },
    'ft_ug' => { column: :ft_ug, converter: Converters::NumberConverter },
    'ft_ftug' => { column: :ft_ftug, converter: Converters::NumberConverter },
    'ftgdnidp' => { column: :ftgdnidp, converter: Converters::NumberConverter },
    'pt_ug' => { column: :pt_ug, converter: Converters::NumberConverter },
    'pt_ftug' => { column: :pt_ftug, converter: Converters::NumberConverter },
    'ptgdnidp' => { column: :ptgdnidp, converter: Converters::NumberConverter },
    'docpp' => { column: :docpp, converter: Converters::NumberConverter },
    'docppsp' => { column: :docppsp, converter: Converters::NumberConverter },
    'tuitvary' => { column: :tuitvary, converter: Converters::NumberConverter },
    'room' => { column: :room, converter: Converters::NumberConverter },
    'xroomcap' => { column: :xroomcap, converter: Converters::BaseConverter },
    'roomcap' => { column: :roomcap, converter: Converters::NumberConverter },
    'board' => { column: :board, converter: Converters::NumberConverter },
    'xmealswk' => { column: :xmealswk, converter: Converters::BaseConverter },
    'mealswk' => { column: :mealswk, converter: Converters::NumberConverter },
    'xroomamt' => { column: :xroomamt, converter: Converters::BaseConverter },
    'roomamt' => { column: :roomamt, converter: Converters::NumberConverter },
    'xbordamt' => { column: :xbordamt, converter: Converters::BaseConverter },
    'boardamt' => { column: :boardamt, converter: Converters::NumberConverter },
    'xrmbdamt' => { column: :xrmbdamt, converter: Converters::BaseConverter },
    'rmbrdamt' => { column: :rmbrdamt, converter: Converters::NumberConverter },
    'alloncam' => { column: :alloncam, converter: Converters::NumberConverter },
    'tuitpl' => { column: :tuitpl, converter: Converters::NumberConverter },
    'tuitpl1' => { column: :tuitpl1, converter: Converters::NumberConverter },
    'tuitpl2' => { column: :tuitpl2, converter: Converters::NumberConverter },
    'tuitpl3' => { column: :tuitpl3, converter: Converters::NumberConverter },
    'tuitpl4' => { column: :tuitpl4, converter: Converters::NumberConverter },
    'disab' => { column: :disab, converter: Converters::NumberConverter },
    'xdisabpc' => { column: :xdisabpc, converter: Converters::BaseConverter },
    'disabpct' => { column: :disabpct, converter: Converters::NumberConverter },
    'distnced' => { column: :distnced, converter: Converters::NumberConverter },
    'dstnced1' => { column: :dstnced1, converter: Converters::NumberConverter },
    'dstnced2' => { column: :dstnced2, converter: Converters::NumberConverter },
    'dstnced3' => { column: :dstnced3, converter: Converters::NumberConverter },
    'vet1' => { column: :vet1, converter: Converters::NumberConverter },
    'vet2' => { column: :vet2, converter: Converters::NumberConverter },
    'vet3' => { column: :vet3, converter: Converters::NumberConverter },
    'vet4' => { column: :vet4, converter: Converters::NumberConverter },
    'vet5' => { column: :vet5, converter: Converters::NumberConverter },
    'vet9' => { column: :vet9, converter: Converters::NumberConverter }
  }.freeze

  validates :cross, presence: true
  validates :vet2, :vet3, :vet4, :vet5, inclusion: { in: (-2..1) }
  validates :distnced, inclusion: { in: [-2, -1, 1, 2] }
  validates :calsys, inclusion: { in: [-2, 1, 2, 3, 4, 5, 6, 7] }
  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.credit_for_mil_training = IpedsIc.coded_to_boolean(vet2)
    self.vet_poc = IpedsIc.coded_to_boolean(vet3)
    self.student_vet_grp_ipeds = IpedsIc.coded_to_boolean(vet4)
    self.soc_member = IpedsIc.coded_to_boolean(vet5)
    self.online_all = IpedsIc.to_online_all(distnced)
    self.calendar = IpedsIc.to_calendar(calsys)
  end

  def self.to_calendar(value)
    return nil if value.nil? || value == -2

    @calendar ||= { 1 => 'semesters', 2 => 'quarters' }
    @calendar[value] || 'nontraditional'
  end

  def self.to_online_all(value)
    value -= 1 if value.present?
    coded_to_boolean(value)
  end

  def self.coded_to_boolean(value)
    return nil if value.nil? || value.negative?

    Converters::BooleanConverter.convert(value)
  end
end
