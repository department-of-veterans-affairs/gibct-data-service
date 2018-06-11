# frozen_string_literal: true

class IpedsIc < ActiveRecord::Base
  include CsvHelper

  COLS_USED_IN_INSTITUTION = %i[
    credit_for_mil_training vet_poc student_vet_grp_ipeds
    soc_member calendar online_all
  ].freeze

  # Note do not map the "integer" values to "boolean" values otherwise exports will put true/false instead of 1/0,
  # instead move them to dependent booleans before validation.
  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: CrossConverter },
    'peo1istr' => { column: :peo1istr, converter: NumberConverter },
    'peo2istr' => { column: :peo2istr, converter: NumberConverter },
    'peo3istr' => { column: :peo3istr, converter: NumberConverter },
    'peo4istr' => { column: :peo4istr, converter: NumberConverter },
    'peo5istr' => { column: :peo5istr, converter: NumberConverter },
    'peo6istr' => { column: :peo6istr, converter: NumberConverter },
    'cntlaffi' => { column: :cntlaffi, converter: NumberConverter },
    'pubprime' => { column: :pubprime, converter: NumberConverter },
    'pubsecon' => { column: :pubsecon, converter: NumberConverter },
    'relaffil' => { column: :relaffil, converter: NumberConverter },
    'level1' => { column: :level1, converter: NumberConverter },
    'level2' => { column: :level2, converter: NumberConverter },
    'level3' => { column: :level3, converter: NumberConverter },
    'level4' => { column: :level4, converter: NumberConverter },
    'level5' => { column: :level5, converter: NumberConverter },
    'level6' => { column: :level6, converter: NumberConverter },
    'level7' => { column: :level7, converter: NumberConverter },
    'level8' => { column: :level8, converter: NumberConverter },
    'level12' => { column: :level12, converter: NumberConverter },
    'level17' => { column: :level17, converter: NumberConverter },
    'level18' => { column: :level18, converter: NumberConverter },
    'level19' => { column: :level19, converter: NumberConverter },
    'openadmp' => { column: :openadmp, converter: NumberConverter },
    'credits1' => { column: :credits1, converter: NumberConverter },
    'credits2' => { column: :credits2, converter: NumberConverter },
    'credits3' => { column: :credits3, converter: NumberConverter },
    'credits4' => { column: :credits4, converter: NumberConverter },
    'slo5' => { column: :slo5, converter: NumberConverter },
    'slo51' => { column: :slo51, converter: NumberConverter },
    'slo52' => { column: :slo52, converter: NumberConverter },
    'slo53' => { column: :slo53, converter: NumberConverter },
    'slo6' => { column: :slo6, converter: NumberConverter },
    'slo7' => { column: :slo7, converter: NumberConverter },
    'slo8' => { column: :slo8, converter: NumberConverter },
    'slo81' => { column: :slo81, converter: NumberConverter },
    'slo82' => { column: :slo82, converter: NumberConverter },
    'slo83' => { column: :slo83, converter: NumberConverter },
    'slo9' => { column: :slo9, converter: NumberConverter },
    'yrscoll' => { column: :yrscoll, converter: NumberConverter },
    'stusrv1' => { column: :stusrv1, converter: NumberConverter },
    'stusrv2' => { column: :stusrv2, converter: NumberConverter },
    'stusrv3' => { column: :stusrv3, converter: NumberConverter },
    'stusrv4' => { column: :stusrv4, converter: NumberConverter },
    'stusrv8' => { column: :stusrv8, converter: NumberConverter },
    'stusrv9' => { column: :stusrv9, converter: NumberConverter },
    'libfac' => { column: :libfac, converter: NumberConverter },
    'athassoc' => { column: :athassoc, converter: NumberConverter },
    'assoc1' => { column: :assoc1, converter: NumberConverter },
    'assoc2' => { column: :assoc2, converter: NumberConverter },
    'assoc3' => { column: :assoc3, converter: BaseConverter },
    'assoc4' => { column: :assoc4, converter: NumberConverter },
    'assoc5' => { column: :assoc5, converter: NumberConverter },
    'assoc6' => { column: :assoc6, converter: NumberConverter },
    'sport1' => { column: :sport1, converter: NumberConverter },
    'confno1' => { column: :confno1, converter: NumberConverter },
    'sport2' => { column: :sport2, converter: NumberConverter },
    'confno2' => { column: :confno2, converter: NumberConverter },
    'sport3' => { column: :sport3, converter: NumberConverter },
    'confno3' => { column: :confno3, converter: NumberConverter },
    'sport4' => { column: :sport4, converter: NumberConverter },
    'confno4' => { column: :confno4, converter: NumberConverter },
    'calsys' => { column: :calsys, converter: NumberConverter },
    'xappfeeu' => { column: :xappfeeu, converter: BaseConverter },
    'applfeeu' => { column: :applfeeu, converter: NumberConverter },
    'xappfeeg' => { column: :xappfeeg, converter: BaseConverter },
    'applfeeg' => { column: :applfeeg, converter: NumberConverter },
    'ft_ug' => { column: :ft_ug, converter: NumberConverter },
    'ft_ftug' => { column: :ft_ftug, converter: NumberConverter },
    'ftgdnidp' => { column: :ftgdnidp, converter: NumberConverter },
    'pt_ug' => { column: :pt_ug, converter: NumberConverter },
    'pt_ftug' => { column: :pt_ftug, converter: NumberConverter },
    'ptgdnidp' => { column: :ptgdnidp, converter: NumberConverter },
    'docpp' => { column: :docpp, converter: NumberConverter },
    'docppsp' => { column: :docppsp, converter: NumberConverter },
    'tuitvary' => { column: :tuitvary, converter: NumberConverter },
    'room' => { column: :room, converter: NumberConverter },
    'xroomcap' => { column: :xroomcap, converter: BaseConverter },
    'roomcap' => { column: :roomcap, converter: NumberConverter },
    'board' => { column: :board, converter: NumberConverter },
    'xmealswk' => { column: :xmealswk, converter: BaseConverter },
    'mealswk' => { column: :mealswk, converter: NumberConverter },
    'xroomamt' => { column: :xroomamt, converter: BaseConverter },
    'roomamt' => { column: :roomamt, converter: NumberConverter },
    'xbordamt' => { column: :xbordamt, converter: BaseConverter },
    'boardamt' => { column: :boardamt, converter: NumberConverter },
    'xrmbdamt' => { column: :xrmbdamt, converter: BaseConverter },
    'rmbrdamt' => { column: :rmbrdamt, converter: NumberConverter },
    'alloncam' => { column: :alloncam, converter: NumberConverter },
    'tuitpl' => { column: :tuitpl, converter: NumberConverter },
    'tuitpl1' => { column: :tuitpl1, converter: NumberConverter },
    'tuitpl2' => { column: :tuitpl2, converter: NumberConverter },
    'tuitpl3' => { column: :tuitpl3, converter: NumberConverter },
    'tuitpl4' => { column: :tuitpl4, converter: NumberConverter },
    'disab' => { column: :disab, converter: NumberConverter },
    'xdisabpc' => { column: :xdisabpc, converter: BaseConverter },
    'disabpct' => { column: :disabpct, converter: NumberConverter },
    'distnced' => { column: :distnced, converter: NumberConverter },
    'dstnced1' => { column: :dstnced1, converter: NumberConverter },
    'dstnced2' => { column: :dstnced2, converter: NumberConverter },
    'dstnced3' => { column: :dstnced3, converter: NumberConverter },
    'vet1' => { column: :vet1, converter: NumberConverter },
    'vet2' => { column: :vet2, converter: NumberConverter },
    'vet3' => { column: :vet3, converter: NumberConverter },
    'vet4' => { column: :vet4, converter: NumberConverter },
    'vet5' => { column: :vet5, converter: NumberConverter },
    'vet9' => { column: :vet9, converter: NumberConverter }
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
    BooleanConverter.convert(value)
  end
end
