GROUP_FILE_TYPES = [
    {
        klass: 'Accreditation',
        required?: true,
        parse_as_xml?: true,
        xml_error_help: 'This upload process was designed for the Excel data file downloaded from <a href="https://ope.ed.gov/dapip/#/download-data-files">DAPIP</a>.',
        types: [
          AccreditationInstituteCampus,
          AccreditationRecord,
          AccreditationAction,
        ]
    },
].freeze

GROUP_FILE_TYPES_NAMES = GROUP_FILE_TYPES.map { |g| g[:klass] }.freeze
GROUP_PARSE_AS_XML = GROUP_FILE_TYPES.select { |g| g[:parse_as_xml?].present? }.map { |g| g[:klass] }.freeze
