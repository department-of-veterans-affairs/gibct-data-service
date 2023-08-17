# frozen_string_literal: true

require 'scorecard_api/client'

module ScorecardApi
  class Service
    # per_page is set to the max according to
    # https://github.com/RTICWDT/open-data-maker/blob/master/lib/data_magic/query_builder.rb#L15
    MAX_PAGE_SIZE = 100

    def self.api_mappings
      { id: :cross,
        ope8_id: :ope,
        ope6_id: :ope6,
        'school.name': :institution,
        'school.city': :city,
        'school.state': :state,
        'school.school_url': :insturl,
        'school.price_calculator_url': :npcurl,
        'school.under_investigation': :hcm2,
        'school.degrees_awarded.predominant': :pred_degree_awarded,
        'school.ownership': :control,
        'school.locale': :locale,
        'school.minority_serving.historically_black': :hbcu,
        'school.minority_serving.predominantly_black': :pbi,
        'school.minority_serving.annh': :annhi,
        'school.minority_serving.tribal': :tribal,
        'school.minority_serving.aanipi': :aanapii,
        'school.minority_serving.hispanic': :hsi,
        'school.minority_serving.nant': :nanti,
        'school.men_only': :menonly,
        'school.women_only': :womenonly,
        'school.religious_affiliation': :relaffil,
        'latest.admissions.sat_scores.25th_percentile.critical_reading': :satvr25,
        'latest.admissions.sat_scores.75th_percentile.critical_reading': :satvr75,
        'latest.admissions.sat_scores.25th_percentile.math': :satmt25,
        'latest.admissions.sat_scores.75th_percentile.math': :satmt75,
        'latest.admissions.sat_scores.25th_percentile.writing': :satwr25,
        'latest.admissions.sat_scores.75th_percentile.writing': :satwr75,
        'latest.admissions.sat_scores.midpoint.critical_reading': :satvrmid,
        'latest.admissions.sat_scores.midpoint.math': :satmtmid,
        'latest.admissions.sat_scores.midpoint.writing': :satwrmid,
        'latest.admissions.act_scores.25th_percentile.cumulative': :actcm25,
        'latest.admissions.act_scores.75th_percentile.cumulative': :actcm75,
        'latest.admissions.act_scores.25th_percentile.english': :acten25,
        'latest.admissions.act_scores.75th_percentile.english': :acten75,
        'latest.admissions.act_scores.25th_percentile.math': :actmt25,
        'latest.admissions.act_scores.75th_percentile.math': :actmt75,
        'latest.admissions.act_scores.25th_percentile.writing': :actwr25,
        'latest.admissions.act_scores.75th_percentile.writing': :actwr75,
        'latest.admissions.act_scores.midpoint.cumulative': :actcmmid,
        'latest.admissions.act_scores.midpoint.english': :actenmid,
        'latest.admissions.act_scores.midpoint.math': :actmtmid,
        'latest.admissions.act_scores.midpoint.writing': :actwrmid,
        'latest.admissions.sat_scores.average.overall': :sat_avg,
        'latest.admissions.sat_scores.average.by_ope_id': :sat_avg_all,
        'latest.academics.program_percentage.agriculture': :pcip01,
        'latest.academics.program_percentage.resources': :pcip03,
        'latest.academics.program_percentage.architecture': :pcip04,
        'latest.academics.program_percentage.ethnic_cultural_gender': :pcip05,
        'latest.academics.program_percentage.communication': :pcip09,
        'latest.academics.program_percentage.communications_technology': :pcip10,
        'latest.academics.program_percentage.computer': :pcip11,
        'latest.academics.program_percentage.personal_culinary': :pcip12,
        'latest.academics.program_percentage.education': :pcip13,
        'latest.academics.program_percentage.engineering': :pcip14,
        'latest.academics.program_percentage.engineering_technology': :pcip15,
        'latest.academics.program_percentage.language': :pcip16,
        'latest.academics.program_percentage.family_consumer_science': :pcip19,
        'latest.academics.program_percentage.legal': :pcip22,
        'latest.academics.program_percentage.english': :pcip23,
        'latest.academics.program_percentage.humanities': :pcip24,
        'latest.academics.program_percentage.library': :pcip25,
        'latest.academics.program_percentage.biological': :pcip26,
        'latest.academics.program_percentage.mathematics': :pcip27,
        'latest.academics.program_percentage.military': :pcip29,
        'latest.academics.program_percentage.multidiscipline': :pcip30,
        'latest.academics.program_percentage.parks_recreation_fitness': :pcip31,
        'latest.academics.program_percentage.philosophy_religious': :pcip38,
        'latest.academics.program_percentage.theology_religious_vocation': :pcip39,
        'latest.academics.program_percentage.physical_science': :pcip40,
        'latest.academics.program_percentage.science_technology': :pcip41,
        'latest.academics.program_percentage.psychology': :pcip42,
        'latest.academics.program_percentage.security_law_enforcement': :pcip43,
        'latest.academics.program_percentage.public_administration_social_service': :pcip44,
        'latest.academics.program_percentage.social_science': :pcip45,
        'latest.academics.program_percentage.construction': :pcip46,
        'latest.academics.program_percentage.mechanic_repair_technology': :pcip47,
        'latest.academics.program_percentage.precision_production': :pcip48,
        'latest.academics.program_percentage.transportation': :pcip49,
        'latest.academics.program_percentage.visual_performing': :pcip50,
        'latest.academics.program_percentage.health': :pcip51,
        'latest.academics.program_percentage.business_marketing': :pcip52,
        'latest.academics.program_percentage.history': :pcip54,
        'school.online_only': :distanceonly,
        'latest.student.size': :undergrad_enrollment,
        'latest.student.demographics.race_ethnicity.white': :ugds_white,
        'latest.student.demographics.race_ethnicity.black': :ugds_black,
        'latest.student.demographics.race_ethnicity.hispanic': :ugds_hisp,
        'latest.student.demographics.race_ethnicity.asian': :ugds_asian,
        'latest.student.demographics.race_ethnicity.aian': :ugds_aian,
        'latest.student.demographics.race_ethnicity.nhpi': :ugds_nhpi,
        'latest.student.demographics.race_ethnicity.two_or_more': :ugds_2mor,
        'latest.student.demographics.race_ethnicity.non_resident_alien': :ugds_nra,
        'latest.student.demographics.race_ethnicity.unknown': :ugds_unkn,
        'latest.student.part_time_share': :pptug_ef,
        'school.operating': :curroper,
        'latest.cost.avg_net_price.public': :npt4_pub,
        'latest.cost.avg_net_price.private': :npt4_priv,
        'latest.cost.net_price.public.by_income_level.0-30000': :npt41_pub,
        'latest.cost.net_price.public.by_income_level.30001-48000': :npt42_pub,
        'latest.cost.net_price.public.by_income_level.48001-75000': :npt43_pub,
        'latest.cost.net_price.public.by_income_level.75001-110000': :npt44_pub,
        'latest.cost.net_price.public.by_income_level.110001-plus': :npt45_pub,
        'latest.cost.net_price.private.by_income_level.0-30000': :npt41_priv,
        'latest.cost.net_price.private.by_income_level.30001-48000': :npt42_priv,
        'latest.cost.net_price.private.by_income_level.48001-75000': :npt43_priv,
        'latest.cost.net_price.private.by_income_level.75001-110000': :npt44_priv,
        'latest.cost.net_price.private.by_income_level.110001-plus': :npt45_priv,
        'latest.aid.pell_grant_rate': :pctpell,
        'latest.student.retention_rate.four_year.full_time': :retention_all_students_ba,
        'latest.student.retention_rate.lt_four_year.full_time': :retention_all_students_otb,
        'latest.student.retention_rate.four_year.part_time': :ret_pt4,
        'latest.student.retention_rate.lt_four_year.part_time': :ret_ptl4,
        'latest.aid.federal_loan_rate': :pctfloan,
        'latest.student.share_25_older': :ug25abv,
        'latest.earnings.10_yrs_after_entry.median': :salary_all_students,
        'latest.earnings.6_yrs_after_entry.percent_greater_than_25000': :gt_25k_p6,
        'latest.aid.median_debt_suppressed.completers.overall': :avg_stu_loan_debt,
        'latest.aid.median_debt_suppressed.completers.monthly_payments': :grad_debt_mdn10yr_supp,
        'latest.repayment.3_yr_repayment_suppressed.overall': :repayment_rate_all_students,
        'latest.completion.rate_suppressed.four_year': :c150_4_pooled_supp,
        'latest.completion.rate_suppressed.lt_four_year_150percent': :c150_l4_pooled_supp,
        'school.alias': :alias
      }.freeze
    end

    def self.populate
      results = []
      response_body = schools_api_call(0) #  call for page 0 to get initial @total
      results.push(*response_body[:results])
      number_of_pages = (response_body[:metadata][:total] / MAX_PAGE_SIZE).to_f.ceil
      (1..number_of_pages).each { |page_num| results.push(*schools_api_call(page_num)[:results]) }
      map_results(results)
    end

    def self.schools_api_call(page)
      params = {
        'fields': api_mappings.keys.join(','),
        'per_page': MAX_PAGE_SIZE.to_s,
        'page': page
      }
      client.schools(params).body
    end

    def self.client
      ScorecardApi::Client.new
    end

    def self.map_results(results)
      results.map do |result|
        scorecard = Scorecard.new
        result.each_pair { |key, value|
          key = restore_key_hyphen(key.to_s) if key.to_s.include?('latest.cost.net_price.public.by_income_level') ||
                                                key.to_s.include?('latest.cost.net_price.private.by_income_level')
          scorecard[api_mappings[key]] = value 
        }
        scorecard.derive_dependent_columns
        scorecard
      end
    end

    def self.restore_key_hyphen(key_string)
      key_string.reverse.sub('_','-').reverse.to_sym
    end
  end
end
