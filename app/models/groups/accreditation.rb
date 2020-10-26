class Accreditation < ModelGroup
  FILE_TYPES = [
      AccreditationInstituteCampus,
      AccreditationRecord,
      AccreditationAction
  ].freeze

end