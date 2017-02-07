# frozen_string_literal: true
class Scorecard < ActiveRecord::Base
  include Loadable, Exportable

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

  USE_COLUMNS = [
    :insturl, :pred_degree_awarded, :locale, :undergrad_enrollment,
    :retention_all_students_ba, :retention_all_students_otb,
    :graduation_rate_all_students, :salary_all_students,
    :repayment_rate_all_students, :avg_stu_loan_debt
  ].freeze

  MAP = {
    'unitid' => { column: :cross, converter: CrossConverter },
    'opeid' => { column: :ope, converter: OpeConverter },
    'opeid6' => { column: :ope6, converter: Ope6Converter },
    'instnm' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'stabbr' => { column: :state, converter: StateConverter },
    'insturl' => { column: :insturl, converter: BaseConverter },
    'npcurl' => { column: :npcurl, converter: BaseConverter },
    'hcm2' => { column: :hcm2, converter: BaseConverter },
    'preddeg' => { column: :pred_degree_awarded, converter: BaseConverter },
    'control' => { column: :control, converter: BaseConverter },
    'locale' => { column: :locale, converter: BaseConverter },
    'hbcu' => { column: :hbcu, converter: BaseConverter },
    'pbi' => { column: :pbi, converter: BaseConverter },
    'annhi' => { column: :annhi, converter: BaseConverter },
    'tribal' => { column: :tribal, converter: BaseConverter },
    'aanapii' => { column: :aanapii, converter: BaseConverter },
    'hsi' => { column: :hsi, converter: BaseConverter },
    'nanti' => { column: :nanti, converter: BaseConverter },
    'menonly' => { column: :menonly, converter: BaseConverter },
    'womenonly' => { column: :womenonly, converter: BaseConverter },
    'relaffil' => { column: :relaffil, converter: BaseConverter },
    'satvr25' => { column: :satvr25, converter: BaseConverter },
    'satvr75' => { column: :satvr75, converter: BaseConverter },
    'satmt25' => { column: :satmt25, converter: BaseConverter },
    'satmt75' => { column: :satmt75, converter: BaseConverter },
    'satwr25' => { column: :satwr25, converter: BaseConverter },
    'satwr75' => { column: :satwr75, converter: BaseConverter },
    'satvrmid' => { column: :satvrmid, converter: BaseConverter },
    'satmtmid' => { column: :satmtmid, converter: BaseConverter },
    'satwrmid' => { column: :satwrmid, converter: BaseConverter },
    'actcm25' => { column: :actcm25, converter: BaseConverter },
    'actcm75' => { column: :actcm75, converter: BaseConverter },
    'acten25' => { column: :acten25, converter: BaseConverter },
    'acten75' => { column: :acten75, converter: BaseConverter },
    'actmt25' => { column: :actmt25, converter: BaseConverter },
    'actmt75' => { column: :actmt75, converter: BaseConverter },
    'actwr25' => { column: :actwr25, converter: BaseConverter },
    'actwr75' => { column: :actwr75, converter: BaseConverter },
    'actcmmid' => { column: :actcmmid, converter: BaseConverter },
    'actenmid' => { column: :actenmid, converter: BaseConverter },
    'actmtmid' => { column: :actmtmid, converter: BaseConverter },
    'actwrmid' => { column: :actwrmid, converter: BaseConverter },
    'sat_avg' => { column: :sat_avg, converter: BaseConverter },
    'sat_avg_all' => { column: :sat_avg_all, converter: BaseConverter },
    'pcip01' => { column: :pcip01, converter: BaseConverter },
    'pcip03' => { column: :pcip03, converter: BaseConverter },
    'pcip04' => { column: :pcip04, converter: BaseConverter },
    'pcip05' => { column: :pcip05, converter: BaseConverter },
    'pcip09' => { column: :pcip09, converter: BaseConverter },
    'pcip10' => { column: :pcip10, converter: BaseConverter },
    'pcip11' => { column: :pcip11, converter: BaseConverter },
    'pcip12' => { column: :pcip12, converter: BaseConverter },
    'pcip13' => { column: :pcip13, converter: BaseConverter },
    'pcip14' => { column: :pcip14, converter: BaseConverter },
    'pcip15' => { column: :pcip15, converter: BaseConverter },
    'pcip16' => { column: :pcip16, converter: BaseConverter },
    'pcip19' => { column: :pcip19, converter: BaseConverter },
    'pcip22' => { column: :pcip22, converter: BaseConverter },
    'pcip23' => { column: :pcip23, converter: BaseConverter },
    'pcip24' => { column: :pcip24, converter: BaseConverter },
    'pcip25' => { column: :pcip25, converter: BaseConverter },
    'pcip26' => { column: :pcip26, converter: BaseConverter },
    'pcip27' => { column: :pcip27, converter: BaseConverter },
    'pcip29' => { column: :pcip29, converter: BaseConverter },
    'pcip30' => { column: :pcip30, converter: BaseConverter },
    'pcip31' => { column: :pcip31, converter: BaseConverter },
    'pcip38' => { column: :pcip38, converter: BaseConverter },
    'pcip39' => { column: :pcip39, converter: BaseConverter },
    'pcip40' => { column: :pcip40, converter: BaseConverter },
    'pcip41' => { column: :pcip41, converter: BaseConverter },
    'pcip42' => { column: :pcip42, converter: BaseConverter },
    'pcip43' => { column: :pcip43, converter: BaseConverter },
    'pcip44' => { column: :pcip44, converter: BaseConverter },
    'pcip45' => { column: :pcip45, converter: BaseConverter },
    'pcip46' => { column: :pcip46, converter: BaseConverter },
    'pcip47' => { column: :pcip47, converter: BaseConverter },
    'pcip48' => { column: :pcip48, converter: BaseConverter },
    'pcip49' => { column: :pcip49, converter: BaseConverter },
    'pcip50' => { column: :pcip50, converter: BaseConverter },
    'pcip51' => { column: :pcip51, converter: BaseConverter },
    'pcip52' => { column: :pcip52, converter: BaseConverter },
    'pcip54' => { column: :pcip54, converter: BaseConverter },
    'distanceonly' => { column: :distanceonly, converter: BaseConverter },
    'ugds' => { column: :undergrad_enrollment, converter: BaseConverter },
    'ugds_white' => { column: :ugds_white, converter: BaseConverter },
    'ugds_black' => { column: :ugds_black, converter: BaseConverter },
    'ugds_hisp' => { column: :ugds_hisp, converter: BaseConverter },
    'ugds_asian' => { column: :ugds_asian, converter: BaseConverter },
    'ugds_aian' => { column: :ugds_aian, converter: BaseConverter },
    'ugds_nhpi' => { column: :ugds_nhpi, converter: BaseConverter },
    'ugds_2mor' => { column: :ugds_2mor, converter: BaseConverter },
    'ugds_nra' => { column: :ugds_nra, converter: BaseConverter },
    'ugds_unkn' => { column: :ugds_unkn, converter: BaseConverter },
    'pptug_ef' => { column: :pptug_ef, converter: BaseConverter },
    'curroper' => { column: :curroper, converter: BaseConverter },
    'npt4_pub' => { column: :npt4_pub, converter: BaseConverter },
    'npt4_priv' => { column: :npt4_priv, converter: BaseConverter },
    'npt41_pub' => { column: :npt41_pub, converter: BaseConverter },
    'npt42_pub' => { column: :npt42_pub, converter: BaseConverter },
    'npt43_pub' => { column: :npt43_pub, converter: BaseConverter },
    'npt44_pub' => { column: :npt44_pub, converter: BaseConverter },
    'npt45_pub' => { column: :npt45_pub, converter: BaseConverter },
    'npt41_priv' => { column: :npt41_priv, converter: BaseConverter },
    'npt42_priv' => { column: :npt42_priv, converter: BaseConverter },
    'npt43_priv' => { column: :npt43_priv, converter: BaseConverter },
    'npt44_priv' => { column: :npt44_priv, converter: BaseConverter },
    'npt45_priv' => { column: :npt45_priv, converter: BaseConverter },
    'pctpell' => { column: :pctpell, converter: BaseConverter },
    'ret_ft4' => { column: :retention_all_students_ba, converter: BaseConverter },
    'ret_ftl4' => { column: :retention_all_students_otb, converter: BaseConverter },
    'ret_pt4' => { column: :ret_pt4, converter: BaseConverter },
    'ret_ptl4' => { column: :ret_ptl4, converter: BaseConverter },
    'pctfloan' => { column: :pctfloan, converter: BaseConverter },
    'ug25abv' => { column: :ug25abv, converter: BaseConverter },
    'md_earn_wne_p10' => { column: :salary_all_students, converter: BaseConverter },
    'gt_25k_p6' => { column: :gt_25k_p6, converter: BaseConverter },
    'grad_debt_mdn_supp' => { column: :avg_stu_loan_debt, converter: BaseConverter },
    'grad_debt_mdn10yr_supp' => { column: :avg_stu_loan_debt, converter: BaseConverter },
    'rpy_3yr_rt_supp' => { column: :repayment_rate_all_students, converter: BaseConverter },
    'c150_4_pooled_supp' => { column: :c150_4_pooled_supp, converter: BaseConverter },
    'c150_l4_pooled_supp' => { column: :c150_l4_pooled_supp, converter: BaseConverter }
  }.freeze

  before_validation :derive_dependent_columns

  def derive_dependent_columns
    self.graduation_rate_all_students = to_graduation_rate_all_students
    self.ope6 = Ope6Converter.convert(ope)

    true
  end

  def to_graduation_rate_all_students
    c150_4_pooled_supp || c150_l4_pooled_supp
  end
end
