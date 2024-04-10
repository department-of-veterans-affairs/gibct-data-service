# frozen_string_literal: true

class Scorecard < ImportableRecord
  validates :cross, presence: true
  validates :pred_degree_awarded, inclusion: { in: (0..4) }
  validates :locale, inclusion: { in: [-3, 11, 12, 13, 21, 22, 23, 31, 32, 33, 41, 42, 43] }, allow_blank: true
  validates :undergrad_enrollment, numericality: { only_integer: true }, allow_blank: true
  validates :retention_all_students_ba, numericality: true, allow_blank: true
  validates :retention_all_students_otb, numericality: true, allow_blank: true
  validates :salary_all_students, numericality: { only_integer: true }, allow_blank: true
  validates :avg_stu_loan_debt, numericality: true, allow_blank: true
  validates :repayment_rate_all_students, numericality: true, allow_blank: true
  validates :c150_l4_pooled_supp, numericality: true, allow_blank: true
  validates :c150_4_pooled_supp, numericality: true, allow_blank: true
  validates :graduation_rate_all_students, numericality: true, allow_blank: true

  COLS_USED_IN_INSTITUTION = %i[
    insturl pred_degree_awarded locale undergrad_enrollment
    retention_all_students_ba retention_all_students_otb
    graduation_rate_all_students salary_all_students
    repayment_rate_all_students avg_stu_loan_debt
    hbcu menonly womenonly relaffil hcm2 pctfloan
    hsi nanti annhi aanapii pbi tribal
  ].freeze

  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: Converters::CrossConverter },
    'opeid' => { column: :ope, converter: Converters::OpeConverter },
    'opeid6' => { column: :ope6, converter: Converters::Ope6Converter },
    'instnm' => { column: :institution, converter: Converters::InstitutionConverter },
    'city' => { column: :city, converter: Converters::BaseConverter },
    'stabbr' => { column: :state, converter: Converters::StateConverter },
    'insturl' => { column: :insturl, converter: Converters::BaseConverter },
    'npcurl' => { column: :npcurl, converter: Converters::BaseConverter },
    'hcm2' => { column: :hcm2, converter: Converters::NumberConverter },
    'preddeg' => { column: :pred_degree_awarded, converter: Converters::NumberConverter },
    'control' => { column: :control, converter: Converters::NumberConverter },
    'locale' => { column: :locale, converter: Converters::NumberConverter },
    'hbcu' => { column: :hbcu, converter: Converters::NumberConverter },
    'pbi' => { column: :pbi, converter: Converters::NumberConverter },
    'annhi' => { column: :annhi, converter: Converters::NumberConverter },
    'tribal' => { column: :tribal, converter: Converters::NumberConverter },
    'aanapii' => { column: :aanapii, converter: Converters::NumberConverter },
    'hsi' => { column: :hsi, converter: Converters::NumberConverter },
    'nanti' => { column: :nanti, converter: Converters::NumberConverter },
    'menonly' => { column: :menonly, converter: Converters::NumberConverter },
    'womenonly' => { column: :womenonly, converter: Converters::NumberConverter },
    'relaffil' => { column: :relaffil, converter: Converters::NumberConverter },
    'satvr25' => { column: :satvr25, converter: Converters::NumberConverter },
    'satvr75' => { column: :satvr75, converter: Converters::NumberConverter },
    'satmt25' => { column: :satmt25, converter: Converters::NumberConverter },
    'satmt75' => { column: :satmt75, converter: Converters::NumberConverter },
    'satwr25' => { column: :satwr25, converter: Converters::NumberConverter },
    'satwr75' => { column: :satwr75, converter: Converters::NumberConverter },
    'satvrmid' => { column: :satvrmid, converter: Converters::NumberConverter },
    'satmtmid' => { column: :satmtmid, converter: Converters::NumberConverter },
    'satwrmid' => { column: :satwrmid, converter: Converters::NumberConverter },
    'actcm25' => { column: :actcm25, converter: Converters::NumberConverter },
    'actcm75' => { column: :actcm75, converter: Converters::NumberConverter },
    'acten25' => { column: :acten25, converter: Converters::NumberConverter },
    'acten75' => { column: :acten75, converter: Converters::NumberConverter },
    'actmt25' => { column: :actmt25, converter: Converters::NumberConverter },
    'actmt75' => { column: :actmt75, converter: Converters::NumberConverter },
    'actwr25' => { column: :actwr25, converter: Converters::NumberConverter },
    'actwr75' => { column: :actwr75, converter: Converters::NumberConverter },
    'actcmmid' => { column: :actcmmid, converter: Converters::NumberConverter },
    'actenmid' => { column: :actenmid, converter: Converters::NumberConverter },
    'actmtmid' => { column: :actmtmid, converter: Converters::NumberConverter },
    'actwrmid' => { column: :actwrmid, converter: Converters::NumberConverter },
    'sat_avg' => { column: :sat_avg, converter: Converters::NumberConverter },
    'sat_avg_all' => { column: :sat_avg_all, converter: Converters::NumberConverter },
    'pcip01' => { column: :pcip01, converter: Converters::NumberConverter },
    'pcip03' => { column: :pcip03, converter: Converters::NumberConverter },
    'pcip04' => { column: :pcip04, converter: Converters::NumberConverter },
    'pcip05' => { column: :pcip05, converter: Converters::NumberConverter },
    'pcip09' => { column: :pcip09, converter: Converters::NumberConverter },
    'pcip10' => { column: :pcip10, converter: Converters::NumberConverter },
    'pcip11' => { column: :pcip11, converter: Converters::NumberConverter },
    'pcip12' => { column: :pcip12, converter: Converters::NumberConverter },
    'pcip13' => { column: :pcip13, converter: Converters::NumberConverter },
    'pcip14' => { column: :pcip14, converter: Converters::NumberConverter },
    'pcip15' => { column: :pcip15, converter: Converters::NumberConverter },
    'pcip16' => { column: :pcip16, converter: Converters::NumberConverter },
    'pcip19' => { column: :pcip19, converter: Converters::NumberConverter },
    'pcip22' => { column: :pcip22, converter: Converters::NumberConverter },
    'pcip23' => { column: :pcip23, converter: Converters::NumberConverter },
    'pcip24' => { column: :pcip24, converter: Converters::NumberConverter },
    'pcip25' => { column: :pcip25, converter: Converters::NumberConverter },
    'pcip26' => { column: :pcip26, converter: Converters::NumberConverter },
    'pcip27' => { column: :pcip27, converter: Converters::NumberConverter },
    'pcip29' => { column: :pcip29, converter: Converters::NumberConverter },
    'pcip30' => { column: :pcip30, converter: Converters::NumberConverter },
    'pcip31' => { column: :pcip31, converter: Converters::NumberConverter },
    'pcip38' => { column: :pcip38, converter: Converters::NumberConverter },
    'pcip39' => { column: :pcip39, converter: Converters::NumberConverter },
    'pcip40' => { column: :pcip40, converter: Converters::NumberConverter },
    'pcip41' => { column: :pcip41, converter: Converters::NumberConverter },
    'pcip42' => { column: :pcip42, converter: Converters::NumberConverter },
    'pcip43' => { column: :pcip43, converter: Converters::NumberConverter },
    'pcip44' => { column: :pcip44, converter: Converters::NumberConverter },
    'pcip45' => { column: :pcip45, converter: Converters::NumberConverter },
    'pcip46' => { column: :pcip46, converter: Converters::NumberConverter },
    'pcip47' => { column: :pcip47, converter: Converters::NumberConverter },
    'pcip48' => { column: :pcip48, converter: Converters::NumberConverter },
    'pcip49' => { column: :pcip49, converter: Converters::NumberConverter },
    'pcip50' => { column: :pcip50, converter: Converters::NumberConverter },
    'pcip51' => { column: :pcip51, converter: Converters::NumberConverter },
    'pcip52' => { column: :pcip52, converter: Converters::NumberConverter },
    'pcip54' => { column: :pcip54, converter: Converters::NumberConverter },
    'distanceonly' => { column: :distanceonly, converter: Converters::NumberConverter },
    'ugds' => { column: :undergrad_enrollment, converter: Converters::NumberConverter },
    'ugds_white' => { column: :ugds_white, converter: Converters::NumberConverter },
    'ugds_black' => { column: :ugds_black, converter: Converters::NumberConverter },
    'ugds_hisp' => { column: :ugds_hisp, converter: Converters::NumberConverter },
    'ugds_asian' => { column: :ugds_asian, converter: Converters::NumberConverter },
    'ugds_aian' => { column: :ugds_aian, converter: Converters::NumberConverter },
    'ugds_nhpi' => { column: :ugds_nhpi, converter: Converters::NumberConverter },
    'ugds_2mor' => { column: :ugds_2mor, converter: Converters::NumberConverter },
    'ugds_nra' => { column: :ugds_nra, converter: Converters::NumberConverter },
    'ugds_unkn' => { column: :ugds_unkn, converter: Converters::NumberConverter },
    'pptug_ef' => { column: :pptug_ef, converter: Converters::NumberConverter },
    'curroper' => { column: :curroper, converter: Converters::NumberConverter },
    'npt4_pub' => { column: :npt4_pub, converter: Converters::NumberConverter },
    'npt4_priv' => { column: :npt4_priv, converter: Converters::NumberConverter },
    'npt41_pub' => { column: :npt41_pub, converter: Converters::NumberConverter },
    'npt42_pub' => { column: :npt42_pub, converter: Converters::NumberConverter },
    'npt43_pub' => { column: :npt43_pub, converter: Converters::NumberConverter },
    'npt44_pub' => { column: :npt44_pub, converter: Converters::NumberConverter },
    'npt45_pub' => { column: :npt45_pub, converter: Converters::NumberConverter },
    'npt41_priv' => { column: :npt41_priv, converter: Converters::NumberConverter },
    'npt42_priv' => { column: :npt42_priv, converter: Converters::NumberConverter },
    'npt43_priv' => { column: :npt43_priv, converter: Converters::NumberConverter },
    'npt44_priv' => { column: :npt44_priv, converter: Converters::NumberConverter },
    'npt45_priv' => { column: :npt45_priv, converter: Converters::NumberConverter },
    'pctpell' => { column: :pctpell, converter: Converters::NumberConverter },
    'ret_ft4' => { column: :retention_all_students_ba, converter: Converters::NumberConverter },
    'ret_ftl4' => { column: :retention_all_students_otb, converter: Converters::NumberConverter },
    'ret_pt4' => { column: :ret_pt4, converter: Converters::NumberConverter },
    'ret_ptl4' => { column: :ret_ptl4, converter: Converters::NumberConverter },
    'pctfloan' => { column: :pctfloan, converter: Converters::NumberConverter },
    'ug25abv' => { column: :ug25abv, converter: Converters::NumberConverter },
    'md_earn_wne_p10' => { column: :salary_all_students, converter: Converters::NumberConverter },
    'gt_25k_p6' => { column: :gt_25k_p6, converter: Converters::NumberConverter },
    'grad_debt_mdn_supp' => { column: :avg_stu_loan_debt, converter: Converters::NumberConverter },
    'grad_debt_mdn10yr_supp' => { column: :grad_debt_mdn10yr_supp, converter: Converters::NumberConverter },
    'rpy_3yr_rt_supp' => { column: :repayment_rate_all_students, converter: Converters::NumberConverter },
    'c150_4_pooled_supp' => { column: :c150_4_pooled_supp, converter: Converters::NumberConverter },
    'c150_l4_pooled_supp' => { column: :c150_l4_pooled_supp, converter: Converters::NumberConverter },
    'alias' => { column: :alias, converter: Converters::BaseConverter }
  }.freeze

  after_initialize :derive_dependent_columns

  self.ignored_columns = %w[longitude latitude]

  POPULATE_SUCCESS_MESSAGE = 'Scorecard CSV table populated from https://collegescorecard.ed.gov/data/'
  API_SOURCE = 'https://collegescorecard.ed.gov/data/'

  def self.populate
    results = ScorecardApi::Service.populate
    load(results) if results.any?
    results.any?
  end

  def derive_dependent_columns
    self.graduation_rate_all_students = to_graduation_rate_all_students
    self.ope6 = Converters::Ope6Converter.convert(ope)
  end

  def to_graduation_rate_all_students
    c150_4_pooled_supp || c150_l4_pooled_supp
  end
end
