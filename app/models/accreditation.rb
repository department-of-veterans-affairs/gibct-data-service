class Accreditation < ActiveRecord::Base
  ACCREDITATIONS = {
    "Regional" => ["middle", "new england", "north central", "southern", "western"],
    "National" => ["career schools", "continuing education", "independent colleges", 
      "biblical", "occupational", "distance", "new york", "transnational"],
    "Hybrid" => ["acupuncture", "nursing", "health education", "liberal","legal", 
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

  #############################################################################
  ## csv_accreditation_type=
  ## Strips whitespace and sets value to downcase
  #############################################################################
  def csv_accreditation_type=(value)
    write_attribute(:csv_accreditation_type, value.try(:strip).try(:downcase))
  end

  #############################################################################
  ## accreditation_status=
  ## Strips whitespace and sets value to downcase
  #############################################################################
  def accreditation_status=(value)
    write_attribute(:accreditation_status, value.try(:strip).try(:downcase))
  end

  #############################################################################
  ## periods=
  ## Strips whitespace and sets value to downcase
  #############################################################################
  def periods=(value)
    write_attribute(:periods, value.try(:strip).try(:downcase))
  end

  #############################################################################
  ## ope=
  ## Strips whitespace and sets value to downcase, and pads ope with 0s
  #############################################################################
  def ope=(value)
    value = value.try(:strip).try(:downcase)
    value = nil if value.blank? || value == 'none' 

    write_attribute(:ope, DS::OpeId.pad(value))
  end

  #############################################################################
  ## campus_ipeds_unitid=
  ## Strips whitespace and sets value to downcase, and pads ipeds with 0s
  #############################################################################
  def campus_ipeds_unitid=(value)
    value = value.try(:strip).try(:downcase)
    value = nil if value.blank? || value == 'none' 

    write_attribute(:campus_ipeds_unitid, DS::IpedsId.pad(value))
  end

  #############################################################################
  ## institution_ipeds_unitid=
  ## Strips whitespace and sets value to downcase, and pads ipeds with 0s
  #############################################################################
  def institution_ipeds_unitid=(value)
    value = value.try(:strip).try(:downcase)
    value = nil if value.blank? || value == 'none' 

    write_attribute(:institution_ipeds_unitid, DS::IpedsId.pad(value))
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
        return (self.accreditation_type = key) if agency_name =~ Regexp.new(exp, true)
      end
    end
  end

  #############################################################################
  ## set_derived_fields
  ## Performs derivation for field values not taken directly from a csv.
  #############################################################################
  def set_derived_fields
    self.ope6 = DS::OpeId.to_ope6(ope)
    self.cross = to_cross
    self.institution = to_institution
  end
end
