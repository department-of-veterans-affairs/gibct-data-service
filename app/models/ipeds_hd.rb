# frozen_string_literal: true

class IpedsHd < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[vet_tuition_policy_url f1sysnam f1syscod].freeze

  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: Converters::CrossConverter },
    'instnm' => { column: :institution, converter: Converters::InstitutionConverter },
    'addr' => { column: :addr, converter: Converters::BaseConverter },
    'city' => { column: :city, converter: Converters::BaseConverter },
    'stabbr' => { column: :state, converter: Converters::BaseConverter },
    'zip' => { column: :zip, converter: Converters::ZipConverter },
    'fips' => { column: :fips, converter: Converters::NumberConverter },
    'obereg' => { column: :obereg, converter: Converters::NumberConverter },
    'chfnm' => { column: :chfnm, converter: Converters::BaseConverter },
    'chftitle' => { column: :chftitle, converter: Converters::BaseConverter },
    'gentele' => { column: :gentele, converter: Converters::BaseConverter },
    'ein' => { column: :ein, converter: Converters::BaseConverter },
    'opeid' => { column: :ope, converter: Converters::OpeConverter },
    'opeflag' => { column: :opeflag, converter: Converters::NumberConverter },
    'webaddr' => { column: :webaddr, converter: Converters::BaseConverter },
    'adminurl' => { column: :adminurl, converter: Converters::BaseConverter },
    'faidurl' => { column: :faidurl, converter: Converters::BaseConverter },
    'applurl' => { column: :applurl, converter: Converters::BaseConverter },
    'npricurl' => { column: :npricurl, converter: Converters::BaseConverter },
    'veturl' => { column: :vet_tuition_policy_url, converter: Converters::BaseConverter },
    'athurl' => { column: :athurl, converter: Converters::BaseConverter },
    'sector' => { column: :sector, converter: Converters::NumberConverter },
    'iclevel' => { column: :iclevel, converter: Converters::NumberConverter },
    'control' => { column: :control, converter: Converters::NumberConverter },
    'hloffer' => { column: :hloffer, converter: Converters::NumberConverter },
    'ugoffer' => { column: :ugoffer, converter: Converters::NumberConverter },
    'groffer' => { column: :groffer, converter: Converters::NumberConverter },
    'hdegofr1' => { column: :hdegofr1, converter: Converters::NumberConverter },
    'deggrant' => { column: :deggrant, converter: Converters::NumberConverter },
    'hbcu' => { column: :hbcu, converter: Converters::NumberConverter },
    'hospital' => { column: :hospital, converter: Converters::NumberConverter },
    'medical' => { column: :medical, converter: Converters::NumberConverter },
    'tribal' => { column: :tribal, converter: Converters::NumberConverter },
    'locale' => { column: :locale, converter: Converters::NumberConverter },
    'openpubl' => { column: :openpubl, converter: Converters::NumberConverter },
    'act' => { column: :act, converter: Converters::BaseConverter },
    'newid' => { column: :newid, converter: Converters::NumberConverter },
    'deathyr' => { column: :deathyr, converter: Converters::NumberConverter },
    'closedat' => { column: :closedat, converter: Converters::BaseConverter },
    'cyactive' => { column: :cyactive, converter: Converters::NumberConverter },
    'postsec' => { column: :postsec, converter: Converters::NumberConverter },
    'pseflag' => { column: :pseflag, converter: Converters::NumberConverter },
    'pset4flg' => { column: :pset4flg, converter: Converters::NumberConverter },
    'rptmth' => { column: :rptmth, converter: Converters::NumberConverter },
    'ialias' => { column: :ialias, converter: Converters::UpcaseConverter },
    'instcat' => { column: :instcat, converter: Converters::NumberConverter },
    'ccbasic' => { column: :ccbasic, converter: Converters::NumberConverter },
    'ccipug' => { column: :ccipug, converter: Converters::NumberConverter },
    'ccipgrad' => { column: :ccipgrad, converter: Converters::NumberConverter },
    'ccugprof' => { column: :ccugprof, converter: Converters::NumberConverter },
    'ccenrprf' => { column: :ccenrprf, converter: Converters::NumberConverter },
    'ccsizset' => { column: :ccsizset, converter: Converters::NumberConverter },
    'carnegie' => { column: :carnegie, converter: Converters::NumberConverter },
    'landgrnt' => { column: :landgrnt, converter: Converters::NumberConverter },
    'instsize' => { column: :instsize, converter: Converters::NumberConverter },
    'cbsa' => { column: :cbsa, converter: Converters::NumberConverter },
    'cbsatype' => { column: :cbsatype, converter: Converters::NumberConverter },
    'csa' => { column: :csa, converter: Converters::NumberConverter },
    'necta' => { column: :necta, converter: Converters::NumberConverter },
    'f1systyp' => { column: :f1systyp, converter: Converters::NumberConverter },
    'f1sysnam' => { column: :f1sysnam, converter: Converters::BaseConverter },
    'f1syscod' => { column: :f1syscod, converter: Converters::NumberConverter },
    'countycd' => { column: :countycd, converter: Converters::NumberConverter },
    'countynm' => { column: :countynm, converter: Converters::BaseConverter },
    'cngdstcd' => { column: :cngdstcd, converter: Converters::NumberConverter },
    'dfrcgid' => { column: :dfrcgid, converter: Converters::NumberConverter },
    'dfrcuscg' => { column: :dfrcuscg, converter: Converters::BaseConverter }
  }.freeze

  has_many :crosswalk_issue, dependent: :delete_all
  validates :cross, presence: true

  self.ignored_columns = %w[longitud latitude]

  def full_address
    [addr, city, state, zip].compact
  end
end
