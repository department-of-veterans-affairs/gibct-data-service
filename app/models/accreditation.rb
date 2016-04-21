class Accreditation < ActiveRecord::Base
  include Standardizable

  ACCREDITATIONS = {
    "regional" => ["middle", "new england", "north central", "southern", "western"],
    "national" => ["career schools", "continuing education", "independent colleges", 
      "biblical", "occupational", "distance", "new york", "transnational"],
    "hybrid" => ["acupuncture", "nursing", "health education", "liberal","legal", 
      "funeral", "osteopathic", "pediatric", "theological", "massage", "radiologic", 
      "midwifery", "montessori", "career arts", "design", "dance", "music", 
      "theatre", "chiropractic"]
  }

  LAST_ACTIONS = ["resigned", "terminated", "closed by institution", "probation",
    "show cause", "expired", "no longer recognized", "accredited", 
    "resigned under show cause", "denied full accreditation", "pre-accredited"
  ]

  CSV_ACCREDITATION_TYPES = ['institutional',  'specialized', 'internship/residency']

  USE_COLUMNS = [:accreditation_status, :accreditation_type]

  validates :agency_name, presence: true

  validates :csv_accreditation_type, inclusion: { in: CSV_ACCREDITATION_TYPES }, allow_blank: true
  validates :accreditation_type, inclusion: { in: ACCREDITATIONS.keys }, allow_blank: true
  validates :accreditation_status, inclusion: { in: LAST_ACTIONS }, allow_blank: true

  before_save :set_derived_fields
  before_validation :set_accreditation_type

  override_setters :institution_name, :campus_name, :institution, :ope, :ope6,
    :institution_ipeds_unitid, :campus_ipeds_unitid, :cross,
    :csv_accreditation_type, :accreditation_type, :agency_name, 
    :accreditation_status, :periods

  #############################################################################
  ## institution
  ## Gets the name of the institution.
  #############################################################################
  def to_institution
    campus_name || institution_name
  end

  #############################################################################
  ## cross
  ## Gets the ipeds id.
  #############################################################################
  def to_cross
    campus_ipeds_unitid || institution_ipeds_unitid
  end

  #############################################################################
  ## accreditation_type
  ## Gets the accreditation_type (as understood by the GIBCT).
  #############################################################################
   def set_accreditation_type
    self.accreditation_type = nil

    ACCREDITATIONS.keys.each do |key|
      ACCREDITATIONS[key].each do |exp|
        return (self.accreditation_type = key) if agency_name =~ Regexp.new(exp, true)
      end
    end
  end

  #############################################################################
  ## set_derived_fields
  ## Performs derivation for field values not taken directly from a csv.
  #############################################################################
  def set_derived_fields
    # self.ope6 = DS::OpeId.to_ope6(ope)
    self.cross = to_cross
    self.institution = to_institution
  end
end
