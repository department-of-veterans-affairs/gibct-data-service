class Accreditation < ActiveRecord::Base
  include Standardizable

  ACCREDITATIONS = {
    "REGIONAL" => ["middle", "new england", "north central", "southern", "western"],
    "NATIONAL" => ["career schools", "continuing education", "independent colleges", 
      "biblical", "occupational", "distance", "new york", "transnational"],
    "HYBRID" => ["acupuncture", "nursing", "health education", "liberal","legal", 
      "funeral", "osteopathic", "pediatric", "theological", "massage", "radiologic", 
      "midwifery", "montessori", "career arts", "design", "dance", "music", 
      "theatre", "chiropractic"]
  }

  LAST_ACTIONS = ["resigned", "terminated", "closed by institution", "probation",
    "show cause", "expired", "no longer recognized", "accredited", 
    "resigned under show cause", "denied full accreditation", "pre-accredited"
  ]

  CSV_ACCREDITATION_TYPES = ['INSTITUTIONAL',  'SPECIALIZED', 'INTERNSHIP/RESIDENCY']

  USE_COLUMNS = [:accreditation_status, :accreditation_type]

  validates :agency_name, presence: true
  validate :inclusion_validator

  override_setters :institution_name, :campus_name, :institution, :ope, :ope6,
    :institution_ipeds_unitid, :campus_ipeds_unitid, :cross,
    :csv_accreditation_type, :accreditation_type, :agency_name, 
    :accreditation_status, :periods

  before_save :set_derived_fields
  before_validation :set_accreditation_type

  #############################################################################
  ## lowercase_inclusion_validator
  ## Case insensitive inclusion validator
  #############################################################################
  def lowercase_inclusion_validator(attribute, collection, blank_ok = true)
    return if (var = self[attribute]).blank? && blank_ok

    # if !collection.include?(var.try(:downcase))
    #   errors.add(attribute, "#{var} not in [#{collection.join(', ')}]")
    # end

    # Case insensitive 
    pattern = Regexp.new(var, true)

    if collection.find { |c| Accreditation.match(pattern, c) }.nil?
      errors.add(attribute, "#{var} not in [#{collection.join(', ')}]")
    end
  end

  #############################################################################
  ## inclusion_validator
  ## Case insensitive inclusion validator
  #############################################################################
  def inclusion_validator
    lowercase_inclusion_validator(:csv_accreditation_type, CSV_ACCREDITATION_TYPES)
    lowercase_inclusion_validator(:accreditation_type, ACCREDITATIONS.keys)
    lowercase_inclusion_validator(:accreditation_status, LAST_ACTIONS)
  end

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
        return (self.accreditation_type = key) if Accreditation.match(exp, agency_name)
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
