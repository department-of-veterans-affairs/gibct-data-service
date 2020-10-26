GROUP_FILE_TYPES = [
    {
        klass: 'Accreditation',
        required?: true,
        not_prod_ready?: true,
        parse_as_xml?: true,
        types: [
          AccreditationInstituteCampus,
          AccreditationRecord,
          AccreditationAction,
        ]
    },
].freeze

GROUP_FILE_TYPES_NAMES = GROUP_FILE_TYPES.map { |table| table[:klass] }.freeze
