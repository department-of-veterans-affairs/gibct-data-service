GROUP_FILE_TYPES = [
    {
        klass: 'Accreditation',
        required?: true,
        not_prod_ready?: true,
        types: [
            {
                label: 'InstituteCampus',
                klass: AccreditationInstituteCampus
            },
            {
                label: 'AccreditationRecords',
                klass: AccreditationRecord
            },
            {
                label: 'AccreditationActions',
                klass: AccreditationAction
            },
        ]
    },
].freeze

GROUP_FILE_TYPES_NAMES = GROUP_FILE_TYPES.map { |table| table[:klass] }.freeze
