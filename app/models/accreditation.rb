class Accreditation < ActiveRecord::Base
  ACCREDITATIONS = {
    "Regional" => ["Middle", "New England", "North Central", "Southern", "Western"],
    "National" => ["career schools", "continuing education", "independent colleges", 
      "biblical", "occupational", "distance", "new york", "transnational"],
    "Hybrid" => ["acupuncture", "nursing", "health education", "liberal","legal", 
      "funeral", "osteopathic", "pediatric", "theological", "massage", "radiologic", 
      "midwifery", "montessori", "career arts", "design", "dance", "music", 
      "theatre", "chiropractic"]
  }

  LAST_ACTIONS = ["Resigned", "Terminated", "Closed by Institution", "Probation",
    "Show Cause", "Expired", "No Longer Recognized", "Accredited", 
    "Resigned Under Show Cause", "Denied Full Accreditation", "Pre-Accredited"
  ]

  ACCREDITATION_TYPES = ["Institutional", "Internship/Residency", "Specialized"]

  validates :agency_name, presence: true

  validates :csv_accreditation_type, inclusion: { in: ACCREDITATION_TYPES }
  validates :last_action, inclusion: { in: LAST_ACTIONS }, allow_blank: true

  #############################################################################
  ## institution
  ## Gets the name of the institution.
  #############################################################################
  def institution
    institution_name || campus_name
  end

  #############################################################################
  ## cross
  ## Gets the ipeds id.
  #############################################################################
  def cross
    institution_ipeds_unitid || campus_ipeds_unitid
  end

  #############################################################################
  ## accreditation_status
  ## Gets the accrediation_status (as understood by the GIBCT).
  #############################################################################
  def accreditation_status
    last_action
  end

  #############################################################################
  ## accreditation_type
  ## Gets the accreditation_type (as understood by the GIBCT).
  #############################################################################
   def accreditation_type
    ACCREDITATIONS.keys.each do |key|
      ACCREDITATIONS[key].each do |exp|
        return key if agency_name =~ Regexp.new(exp)
      end
    end

    nil
  end
end
