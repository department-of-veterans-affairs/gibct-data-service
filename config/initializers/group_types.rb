GROUP_FILE_TYPES = [
    {
        klass: 'Accreditation',
        required?: true,
        types: [
          AccreditationInstituteCampus,
          AccreditationRecord,
          AccreditationAction,
        ]
    },
].freeze

GROUP_FILE_TYPES_NAMES = GROUP_FILE_TYPES.map { |g| g[:klass] }.freeze
