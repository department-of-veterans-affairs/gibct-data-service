# frozen_string_literal: true

class Scorecard < ApplicationRecord
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
  ].freeze

  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: CrossConverter },
    'opeid' => { column: :ope, converter: OpeConverter },
    'opeid6' => { column: :ope6, converter: Ope6Converter },
    'instnm' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'stabbr' => { column: :state, converter: StateConverter },
    'insturl' => { column: :insturl, converter: BaseConverter },
    'npcurl' => { column: :npcurl, converter: BaseConverter },
    'hcm2' => { column: :hcm2, converter: NumberConverter },
    'preddeg' => { column: :pred_degree_awarded, converter: NumberConverter },
    'control' => { column: :control, converter: NumberConverter },
    'locale' => { column: :locale, converter: NumberConverter },
    'hbcu' => { column: :hbcu, converter: NumberConverter },
    'pbi' => { column: :pbi, converter: NumberConverter },
    'annhi' => { column: :annhi, converter: NumberConverter },
    'tribal' => { column: :tribal, converter: NumberConverter },
    'aanapii' => { column: :aanapii, converter: NumberConverter },
    'hsi' => { column: :hsi, converter: NumberConverter },
    'nanti' => { column: :nanti, converter: NumberConverter },
    'menonly' => { column: :menonly, converter: NumberConverter },
    'womenonly' => { column: :womenonly, converter: NumberConverter },
    'relaffil' => { column: :relaffil, converter: NumberConverter },
    'satvr25' => { column: :satvr25, converter: NumberConverter },
    'satvr75' => { column: :satvr75, converter: NumberConverter },
    'satmt25' => { column: :satmt25, converter: NumberConverter },
    'satmt75' => { column: :satmt75, converter: NumberConverter },
    'satwr25' => { column: :satwr25, converter: NumberConverter },
    'satwr75' => { column: :satwr75, converter: NumberConverter },
    'satvrmid' => { column: :satvrmid, converter: NumberConverter },
    'satmtmid' => { column: :satmtmid, converter: NumberConverter },
    'satwrmid' => { column: :satwrmid, converter: NumberConverter },
    'actcm25' => { column: :actcm25, converter: NumberConverter },
    'actcm75' => { column: :actcm75, converter: NumberConverter },
    'acten25' => { column: :acten25, converter: NumberConverter },
    'acten75' => { column: :acten75, converter: NumberConverter },
    'actmt25' => { column: :actmt25, converter: NumberConverter },
    'actmt75' => { column: :actmt75, converter: NumberConverter },
    'actwr25' => { column: :actwr25, converter: NumberConverter },
    'actwr75' => { column: :actwr75, converter: NumberConverter },
    'actcmmid' => { column: :actcmmid, converter: NumberConverter },
    'actenmid' => { column: :actenmid, converter: NumberConverter },
    'actmtmid' => { column: :actmtmid, converter: NumberConverter },
    'actwrmid' => { column: :actwrmid, converter: NumberConverter },
    'sat_avg' => { column: :sat_avg, converter: NumberConverter },
    'sat_avg_all' => { column: :sat_avg_all, converter: NumberConverter },
    'pcip01' => { column: :pcip01, converter: NumberConverter },
    'pcip03' => { column: :pcip03, converter: NumberConverter },
    'pcip04' => { column: :pcip04, converter: NumberConverter },
    'pcip05' => { column: :pcip05, converter: NumberConverter },
    'pcip09' => { column: :pcip09, converter: NumberConverter },
    'pcip10' => { column: :pcip10, converter: NumberConverter },
    'pcip11' => { column: :pcip11, converter: NumberConverter },
    'pcip12' => { column: :pcip12, converter: NumberConverter },
    'pcip13' => { column: :pcip13, converter: NumberConverter },
    'pcip14' => { column: :pcip14, converter: NumberConverter },
    'pcip15' => { column: :pcip15, converter: NumberConverter },
    'pcip16' => { column: :pcip16, converter: NumberConverter },
    'pcip19' => { column: :pcip19, converter: NumberConverter },
    'pcip22' => { column: :pcip22, converter: NumberConverter },
    'pcip23' => { column: :pcip23, converter: NumberConverter },
    'pcip24' => { column: :pcip24, converter: NumberConverter },
    'pcip25' => { column: :pcip25, converter: NumberConverter },
    'pcip26' => { column: :pcip26, converter: NumberConverter },
    'pcip27' => { column: :pcip27, converter: NumberConverter },
    'pcip29' => { column: :pcip29, converter: NumberConverter },
    'pcip30' => { column: :pcip30, converter: NumberConverter },
    'pcip31' => { column: :pcip31, converter: NumberConverter },
    'pcip38' => { column: :pcip38, converter: NumberConverter },
    'pcip39' => { column: :pcip39, converter: NumberConverter },
    'pcip40' => { column: :pcip40, converter: NumberConverter },
    'pcip41' => { column: :pcip41, converter: NumberConverter },
    'pcip42' => { column: :pcip42, converter: NumberConverter },
    'pcip43' => { column: :pcip43, converter: NumberConverter },
    'pcip44' => { column: :pcip44, converter: NumberConverter },
    'pcip45' => { column: :pcip45, converter: NumberConverter },
    'pcip46' => { column: :pcip46, converter: NumberConverter },
    'pcip47' => { column: :pcip47, converter: NumberConverter },
    'pcip48' => { column: :pcip48, converter: NumberConverter },
    'pcip49' => { column: :pcip49, converter: NumberConverter },
    'pcip50' => { column: :pcip50, converter: NumberConverter },
    'pcip51' => { column: :pcip51, converter: NumberConverter },
    'pcip52' => { column: :pcip52, converter: NumberConverter },
    'pcip54' => { column: :pcip54, converter: NumberConverter },
    'distanceonly' => { column: :distanceonly, converter: NumberConverter },
    'ugds' => { column: :undergrad_enrollment, converter: NumberConverter },
    'ugds_white' => { column: :ugds_white, converter: NumberConverter },
    'ugds_black' => { column: :ugds_black, converter: NumberConverter },
    'ugds_hisp' => { column: :ugds_hisp, converter: NumberConverter },
    'ugds_asian' => { column: :ugds_asian, converter: NumberConverter },
    'ugds_aian' => { column: :ugds_aian, converter: NumberConverter },
    'ugds_nhpi' => { column: :ugds_nhpi, converter: NumberConverter },
    'ugds_2mor' => { column: :ugds_2mor, converter: NumberConverter },
    'ugds_nra' => { column: :ugds_nra, converter: NumberConverter },
    'ugds_unkn' => { column: :ugds_unkn, converter: NumberConverter },
    'pptug_ef' => { column: :pptug_ef, converter: NumberConverter },
    'curroper' => { column: :curroper, converter: NumberConverter },
    'npt4_pub' => { column: :npt4_pub, converter: NumberConverter },
    'npt4_priv' => { column: :npt4_priv, converter: NumberConverter },
    'npt41_pub' => { column: :npt41_pub, converter: NumberConverter },
    'npt42_pub' => { column: :npt42_pub, converter: NumberConverter },
    'npt43_pub' => { column: :npt43_pub, converter: NumberConverter },
    'npt44_pub' => { column: :npt44_pub, converter: NumberConverter },
    'npt45_pub' => { column: :npt45_pub, converter: NumberConverter },
    'npt41_priv' => { column: :npt41_priv, converter: NumberConverter },
    'npt42_priv' => { column: :npt42_priv, converter: NumberConverter },
    'npt43_priv' => { column: :npt43_priv, converter: NumberConverter },
    'npt44_priv' => { column: :npt44_priv, converter: NumberConverter },
    'npt45_priv' => { column: :npt45_priv, converter: NumberConverter },
    'pctpell' => { column: :pctpell, converter: NumberConverter },
    'ret_ft4' => { column: :retention_all_students_ba, converter: NumberConverter },
    'ret_ftl4' => { column: :retention_all_students_otb, converter: NumberConverter },
    'ret_pt4' => { column: :ret_pt4, converter: NumberConverter },
    'ret_ptl4' => { column: :ret_ptl4, converter: NumberConverter },
    'pctfloan' => { column: :pctfloan, converter: NumberConverter },
    'ug25abv' => { column: :ug25abv, converter: NumberConverter },
    'md_earn_wne_p10' => { column: :salary_all_students, converter: NumberConverter },
    'gt_25k_p6' => { column: :gt_25k_p6, converter: NumberConverter },
    'grad_debt_mdn_supp' => { column: :avg_stu_loan_debt, converter: NumberConverter },
    'grad_debt_mdn10yr_supp' => { column: :avg_stu_loan_debt, converter: NumberConverter },
    'rpy_3yr_rt_supp' => { column: :repayment_rate_all_students, converter: NumberConverter },
    'c150_4_pooled_supp' => { column: :c150_4_pooled_supp, converter: NumberConverter },
    'c150_l4_pooled_supp' => { column: :c150_l4_pooled_supp, converter: NumberConverter },
    'alias' => { column: :alias, converter: BaseConverter }
  }.freeze

  after_initialize :derive_dependent_columns

  POPULATE_SUCCESS_MESSAGE = 'Scorecard CSV table populated from https://collegescorecard.ed.gov/data/'
  API_SOURCE = 'https://collegescorecard.ed.gov/data/'

  def self.populate
    results = ScorecardApi::Service.populate
    load(results) if results.any?
    results.any?
  end

  def derive_dependent_columns
    self.graduation_rate_all_students = to_graduation_rate_all_students
    self.ope6 = Ope6Converter.convert(ope)
  end

  def to_graduation_rate_all_students
    c150_4_pooled_supp || c150_l4_pooled_supp
  end
end
