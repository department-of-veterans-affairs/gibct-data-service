GROUP_FILE_TYPES = [
    {
        klass: 'Accreditation',
        required?: true,
        not_prod_ready?: true,
        types: [
          AccreditationInstituteCampus,
          AccreditationRecord,
          AccreditationAction,
        ]
    },
].freeze

GROUP_FILE_TYPES_NAMES = GROUP_FILE_TYPES.map { |table| table[:klass] }.freeze
