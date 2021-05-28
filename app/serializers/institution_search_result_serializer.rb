# frozen_string_literal: true

class InstitutionSearchResultSerializer < ActiveModel::Serializer
  attribute :institution, key: :name
  attribute :facility_code
  attribute :physical_city, key: :city
  attribute :physical_state, key: :state
  attribute :physical_country, key: :country
  attribute :accreditation_type
  attribute :gibill, key: :student_count
  attribute :rating_average
  attribute :rating_count
  attribute :institution_type_name, key: :type
  attribute :caution_flags
  attribute :caution_flag
  attribute :student_veteran
  attribute :yr
  attribute :campus_type
  attribute :highest_degree
  attribute :hbcu
  attribute :menonly
  attribute :womenonly
  attribute :relaffil
  attribute :preferred_provider
  attribute :dod_bah
  attribute :bah
  attribute :latitude
  attribute :longitude
  attribute :distance
  attribute :accredited
  attribute :vet_tec_provider

  # a. Accreditation [Institution Summary]
  # c. Length of program [Header]
  # d. Type of school [Header]
  # e. Institution locale [Header]
  # f. Size of school [Header]
  # g. School mission [Used in search results - Not displayed]
  # h. Tuition and fees [EYB]
  # i. GI Bill pays to school [EYB]
  # j. Out of pocket tuition [EYB]
  # k. Housing allowance [EYB]
  # l. Book stipend [EYB]
  # m. Overall rating [Ratings - behind feature flag]
  # n. # of veteran ratings [Ratings - behind feature flag]
  # o. Overall experience Rating [Ratings - behind feature flag]
  # p. Quality of classes Rating [Ratings - behind feature flag]
  # q. Online instruction Rating [Ratings - behind feature flag]
  # r. Job preparation Rating [Ratings - behind feature flag]
  # s. GI bill support Rating [Ratings - behind feature flag]
  # t. Veteran community Rating [Ratings - behind feature flag]
  # u. True to expectations Rating [Ratings - behind feature flag]
  # w. Student complaints [Cautionary information]
  # x. Length of VET TEC programs [VETTEC profile]
  # y. Credit for military training [Additional information]
  # z. Single point of contact [Additional information]
  # aa. Yellow Ribbon [Veteran Programs]
  # ab. Student Veteran Group [Veteran Programs]
  # ac. Principle of Excellence [Veteran Programs]
  # ad. 8 Keys to Veteran Success [Veteran Programs]
  # ae. Military Tuition Assistance (TA) [Veteran Programs]
  # af. Priority Enrollment [Veteran Programs]

  def caution_flags
    object.caution_flags.map do |flag|
      CautionFlagSerializer.new(flag)
    end
  end
end
