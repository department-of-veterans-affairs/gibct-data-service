# frozen_string_literal: true

class IpedsHd < ApplicationRecord


  COLS_USED_IN_INSTITUTION = %i[vet_tuition_policy_url f1sysnam f1syscod].freeze

  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: CrossConverter },
    'instnm' => { column: :institution, converter: InstitutionConverter },
    'addr' => { column: :addr, converter: BaseConverter },
    'city' => { column: :city, converter: BaseConverter },
    'stabbr' => { column: :state, converter: BaseConverter },
    'zip' => { column: :zip, converter: ZipConverter },
    'fips' => { column: :fips, converter: NumberConverter },
    'obereg' => { column: :obereg, converter: NumberConverter },
    'chfnm' => { column: :chfnm, converter: BaseConverter },
    'chftitle' => { column: :chftitle, converter: BaseConverter },
    'gentele' => { column: :gentele, converter: BaseConverter },
    'ein' => { column: :ein, converter: BaseConverter },
    'opeid' => { column: :ope, converter: OpeConverter },
    'opeflag' => { column: :opeflag, converter: NumberConverter },
    'webaddr' => { column: :webaddr, converter: BaseConverter },
    'adminurl' => { column: :adminurl, converter: BaseConverter },
    'faidurl' => { column: :faidurl, converter: BaseConverter },
    'applurl' => { column: :applurl, converter: BaseConverter },
    'npricurl' => { column: :npricurl, converter: BaseConverter },
    'veturl' => { column: :vet_tuition_policy_url, converter: BaseConverter },
    'athurl' => { column: :athurl, converter: BaseConverter },
    'sector' => { column: :sector, converter: NumberConverter },
    'iclevel' => { column: :iclevel, converter: NumberConverter },
    'control' => { column: :control, converter: NumberConverter },
    'hloffer' => { column: :hloffer, converter: NumberConverter },
    'ugoffer' => { column: :ugoffer, converter: NumberConverter },
    'groffer' => { column: :groffer, converter: NumberConverter },
    'hdegofr1' => { column: :hdegofr1, converter: NumberConverter },
    'deggrant' => { column: :deggrant, converter: NumberConverter },
    'hbcu' => { column: :hbcu, converter: NumberConverter },
    'hospital' => { column: :hospital, converter: NumberConverter },
    'medical' => { column: :medical, converter: NumberConverter },
    'tribal' => { column: :tribal, converter: NumberConverter },
    'locale' => { column: :locale, converter: NumberConverter },
    'openpubl' => { column: :openpubl, converter: NumberConverter },
    'act' => { column: :act, converter: BaseConverter },
    'newid' => { column: :newid, converter: NumberConverter },
    'deathyr' => { column: :deathyr, converter: NumberConverter },
    'closedat' => { column: :closedat, converter: BaseConverter },
    'cyactive' => { column: :cyactive, converter: NumberConverter },
    'postsec' => { column: :postsec, converter: NumberConverter },
    'pseflag' => { column: :pseflag, converter: NumberConverter },
    'pset4flg' => { column: :pset4flg, converter: NumberConverter },
    'rptmth' => { column: :rptmth, converter: NumberConverter },
    'ialias' => { column: :ialias, converter: UpcaseConverter },
    'instcat' => { column: :instcat, converter: NumberConverter },
    'ccbasic' => { column: :ccbasic, converter: NumberConverter },
    'ccipug' => { column: :ccipug, converter: NumberConverter },
    'ccipgrad' => { column: :ccipgrad, converter: NumberConverter },
    'ccugprof' => { column: :ccugprof, converter: NumberConverter },
    'ccenrprf' => { column: :ccenrprf, converter: NumberConverter },
    'ccsizset' => { column: :ccsizset, converter: NumberConverter },
    'carnegie' => { column: :carnegie, converter: NumberConverter },
    'landgrnt' => { column: :landgrnt, converter: NumberConverter },
    'instsize' => { column: :instsize, converter: NumberConverter },
    'cbsa' => { column: :cbsa, converter: NumberConverter },
    'cbsatype' => { column: :cbsatype, converter: NumberConverter },
    'csa' => { column: :csa, converter: NumberConverter },
    'necta' => { column: :necta, converter: NumberConverter },
    'f1systyp' => { column: :f1systyp, converter: NumberConverter },
    'f1sysnam' => { column: :f1sysnam, converter: BaseConverter },
    'f1syscod' => { column: :f1syscod, converter: NumberConverter },
    'countycd' => { column: :countycd, converter: NumberConverter },
    'countynm' => { column: :countynm, converter: BaseConverter },
    'cngdstcd' => { column: :cngdstcd, converter: NumberConverter },
    'longitud' => { column: :longitud, converter: NumberConverter },
    'latitude' => { column: :latitude, converter: NumberConverter },
    'dfrcgid' => { column: :dfrcgid, converter: NumberConverter },
    'dfrcuscg' => { column: :dfrcuscg, converter: BaseConverter }
  }.freeze

  has_many :crosswalk_issue, dependent: :delete_all
  validates :cross, presence: true

  def full_address
    [addr, city, state, zip].compact
  end
end
