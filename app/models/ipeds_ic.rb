# frozen_string_literal: true
class IpedsIc < ActiveRecord::Base
  include Loadable, Exportable

  USE_COLUMNS = [
    :credit_for_mil_training, :vet_poc, :student_vet_grp_ipeds,
    :soc_member, :calendar, :online_all
  ].freeze

  # Note do not map the "integer" values to "boolean" values otherwise exports will put true/false instead of 1/0,
  # instead move them to dependent booleans before validation.
  MAP = {
    'unitid' => { column: :cross, converter: CrossConverter },
    'peo1istr' => { column: :peo1istr, converter: BaseConverter },
    'peo2istr' => { column: :peo2istr, converter: BaseConverter },
    'peo3istr' => { column: :peo3istr, converter: BaseConverter },
    'peo4istr' => { column: :peo4istr, converter: BaseConverter },
    'peo5istr' => { column: :peo5istr, converter: BaseConverter },
    'peo6istr' => { column: :peo6istr, converter: BaseConverter },
    'cntlaffi' => { column: :cntlaffi, converter: BaseConverter },
    'pubprime' => { column: :pubprime, converter: BaseConverter },
    'pubsecon' => { column: :pubsecon, converter: BaseConverter },
    'relaffil' => { column: :relaffil, converter: BaseConverter },
    'level1' => { column: :level1, converter: BaseConverter },
    'level2' => { column: :level2, converter: BaseConverter },
    'level3' => { column: :level3, converter: BaseConverter },
    'level4' => { column: :level4, converter: BaseConverter },
    'level5' => { column: :level5, converter: BaseConverter },
    'level6' => { column: :level6, converter: BaseConverter },
    'level7' => { column: :level7, converter: BaseConverter },
    'level8' => { column: :level8, converter: BaseConverter },
    'level12' => { column: :level12, converter: BaseConverter },
    'level17' => { column: :level17, converter: BaseConverter },
    'level18' => { column: :level18, converter: BaseConverter },
    'level19' => { column: :level19, converter: BaseConverter },
    'openadmp' => { column: :openadmp, converter: BaseConverter },
    'credits1' => { column: :credits1, converter: BaseConverter },
    'credits2' => { column: :credits2, converter: BaseConverter },
    'credits3' => { column: :credits3, converter: BaseConverter },
    'credits4' => { column: :credits4, converter: BaseConverter },
    'slo5' => { column: :slo5, converter: BaseConverter },
    'slo51' => { column: :slo51, converter: BaseConverter },
    'slo52' => { column: :slo52, converter: BaseConverter },
    'slo53' => { column: :slo53, converter: BaseConverter },
    'slo6' => { column: :slo6, converter: BaseConverter },
    'slo7' => { column: :slo7, converter: BaseConverter },
    'slo8' => { column: :slo8, converter: BaseConverter },
    'slo81' => { column: :slo81, converter: BaseConverter },
    'slo82' => { column: :slo82, converter: BaseConverter },
    'slo83' => { column: :slo83, converter: BaseConverter },
    'slo9' => { column: :slo9, converter: BaseConverter },
    'yrscoll' => { column: :yrscoll, converter: BaseConverter },
    'stusrv1' => { column: :stusrv1, converter: BaseConverter },
    'stusrv2' => { column: :stusrv2, converter: BaseConverter },
    'stusrv3' => { column: :stusrv3, converter: BaseConverter },
    'stusrv4' => { column: :stusrv4, converter: BaseConverter },
    'stusrv8' => { column: :stusrv8, converter: BaseConverter },
    'stusrv9' => { column: :stusrv9, converter: BaseConverter },
    'libfac' => { column: :libfac, converter: BaseConverter },
    'athassoc' => { column: :athassoc, converter: BaseConverter },
    'assoc1' => { column: :assoc1, converter: BaseConverter },
    'assoc2' => { column: :assoc2, converter: BaseConverter },
    'assoc3' => { column: :assoc3, converter: BaseConverter },
    'assoc4' => { column: :assoc4, converter: BaseConverter },
    'assoc5' => { column: :assoc5, converter: BaseConverter },
    'assoc6' => { column: :assoc6, converter: BaseConverter },
    'sport1' => { column: :sport1, converter: BaseConverter },
    'confno1' => { column: :confno1, converter: BaseConverter },
    'sport2' => { column: :sport2, converter: BaseConverter },
    'confno2' => { column: :confno2, converter: BaseConverter },
    'sport3' => { column: :sport3, converter: BaseConverter },
    'confno3' => { column: :confno3, converter: BaseConverter },
    'sport4' => { column: :sport4, converter: BaseConverter },
    'confno4' => { column: :confno4, converter: BaseConverter },
    'calsys' => { column: :calsys, converter: BaseConverter },
    'xappfeeu' => { column: :xappfeeu, converter: BaseConverter },
    'applfeeu' => { column: :applfeeu, converter: BaseConverter },
    'xappfeeg' => { column: :xappfeeg, converter: BaseConverter },
    'applfeeg' => { column: :applfeeg, converter: BaseConverter },
    'ft_ug' => { column: :ft_ug, converter: BaseConverter },
    'ft_ftug' => { column: :ft_ftug, converter: BaseConverter },
    'ftgdnidp' => { column: :ftgdnidp, converter: BaseConverter },
    'pt_ug' => { column: :pt_ug, converter: BaseConverter },
    'pt_ftug' => { column: :pt_ftug, converter: BaseConverter },
    'ptgdnidp' => { column: :ptgdnidp, converter: BaseConverter },
    'docpp' => { column: :docpp, converter: BaseConverter },
    'docppsp' => { column: :docppsp, converter: BaseConverter },
    'tuitvary' => { column: :tuitvary, converter: BaseConverter },
    'room' => { column: :room, converter: BaseConverter },
    'xroomcap' => { column: :xroomcap, converter: BaseConverter },
    'roomcap' => { column: :roomcap, converter: BaseConverter },
    'board' => { column: :board, converter: BaseConverter },
    'xmealswk' => { column: :xmealswk, converter: BaseConverter },
    'mealswk' => { column: :mealswk, converter: BaseConverter },
    'xroomamt' => { column: :xroomamt, converter: BaseConverter },
    'roomamt' => { column: :roomamt, converter: BaseConverter },
    'xbordamt' => { column: :xbordamt, converter: BaseConverter },
    'boardamt' => { column: :boardamt, converter: BaseConverter },
    'xrmbdamt' => { column: :xrmbdamt, converter: BaseConverter },
    'rmbrdamt' => { column: :rmbrdamt, converter: BaseConverter },
    'alloncam' => { column: :alloncam, converter: BaseConverter },
    'tuitpl' => { column: :tuitpl, converter: BaseConverter },
    'tuitpl1' => { column: :tuitpl1, converter: BaseConverter },
    'tuitpl2' => { column: :tuitpl2, converter: BaseConverter },
    'tuitpl3' => { column: :tuitpl3, converter: BaseConverter },
    'tuitpl4' => { column: :tuitpl4, converter: BaseConverter },
    'disab' => { column: :disab, converter: BaseConverter },
    'xdisabpc' => { column: :xdisabpc, converter: BaseConverter },
    'disabpct' => { column: :disabpct, converter: BaseConverter },
    'distnced' => { column: :distnced, converter: BaseConverter },
    'dstnced1' => { column: :dstnced1, converter: BaseConverter },
    'dstnced2' => { column: :dstnced2, converter: BaseConverter },
    'dstnced3' => { column: :dstnced3, converter: BaseConverter },
    'vet1' => { column: :vet1, converter: BaseConverter },
    'vet2' => { column: :vet2, converter: BaseConverter },
    'vet3' => { column: :vet3, converter: BaseConverter },
    'vet4' => { column: :vet4, converter: BaseConverter },
    'vet5' => { column: :vet5, converter: BaseConverter },
    'vet9' => { column: :vet9, converter: BaseConverter }
  }.freeze

  validates :cross, presence: true
  validates :vet2, :vet3, :vet4, :vet5, inclusion: { in: (-2..1) }
  validates :distnced, inclusion: { in: [-2, -1, 1, 2] }
  validates :calsys, inclusion: { in: [-2, 1, 2, 3, 4, 5, 6, 7] }
  before_validation :derive_dependent_columns

  def derive_dependent_columns
    self.credit_for_mil_training = IpedsIc.coded_to_boolean(vet2)
    self.vet_poc = IpedsIc.coded_to_boolean(vet3)
    self.student_vet_grp_ipeds = IpedsIc.coded_to_boolean(vet4)
    self.soc_member = IpedsIc.coded_to_boolean(vet5)
    self.online_all = IpedsIc.to_online_all(distnced)
    self.calendar = IpedsIc.to_calendar(calsys)

    true
  end

  def self.to_calendar(value)
    return nil if value.nil? || value == -2
    @calendar ||= { 1 => 'semesters', 2 => 'quarters' }
    @calendar[value] || 'nontraditional'
  end

  def self.to_online_all(value)
    value -= 1 unless value.blank?
    coded_to_boolean(value)
  end

  def self.coded_to_boolean(value)
    return nil if value.nil? || value.negative?
    BooleanConverter.convert(value)
  end
end
