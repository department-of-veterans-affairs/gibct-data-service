###############################################################################
## Accreditation
## Represents accreditations and accreditation bodies. Additionally, caution
## flags are derived from some of the data here.
##
## The ACCREDITATIONS hash maps accreditation types (Regional, National, or 
## Hybrid) to substrings in the name of the accrediting body. So, for example,
## if the accrediting agency is the "New England Medical Association", then
## the accreditation is "Regional".
##
## LAST_ACTIONS are an array of strings that refer to changes to accreditation
## from which caution flags are derived ('show cause' and 'probation').
##
## CSV_ACCREDITATION_TYPES are used to detail accreditation types in the CSV.
## Only INSTITUTIONAL accreditation types are recognized by the DS and GIBCT.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class Accreditation < ActiveRecord::Base
  include Standardizable

  ACCREDITATIONS = {
    "REGIONAL" => ["middle", "new england", "north central", "southern", "western"],
    "NATIONAL" => ["career schools", "continuing education", "independent colleges", 
      "biblical", "occupational", "distance", "new york", "transnational"],
    "HYBRID" => ["acupuncture", "nursing", "health education", "liberal", "legal", 
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

  # C.F., the Standardization module.
  override_setters :institution_name, :campus_name, :institution, :ope, :ope6,
    :institution_ipeds_unitid, :campus_ipeds_unitid, :cross,
    :csv_accreditation_type, :accreditation_type, :agency_name, 
    :accreditation_status, :periods

  before_save :set_derived_fields
  before_validation :set_accreditation_type

  #############################################################################
  ## lowercase_inclusion_validator
  ## Case insensitive inclusion validator.
  #############################################################################
  def lowercase_inclusion_validator(attribute, collection, blank_ok = true)
    return if (var = self[attribute]).blank? && blank_ok

    # Case insensitive 
    pattern = Regexp.new(var, true)

    if collection.find { |c| Accreditation.match(pattern, c) }.nil?
      errors.add(attribute, "#{var} not in [#{collection.join(', ')}]")
    end
  end

  #############################################################################
  ## inclusion_validator
  ## Calls the lower case inclusion validator for appropriate fields.
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
    self.cross = to_cross
    self.institution = to_institution
  end
end
