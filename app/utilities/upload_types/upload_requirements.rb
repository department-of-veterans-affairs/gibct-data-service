# frozen_string_literal: true

class UploadRequirements
  class << self
    def requirements_messages(type)
      [validation_messages_presence(type),
       validation_messages_numericality(type),
       validation_messages_uniqueness(type)]
        .compact
    end

    def validation_messages_inclusion(type)
      inclusion = []

      type.validators.each do |validations|
        next unless validations.class == ActiveModel::Validations::InclusionValidator

        inclusion.push({ message: affected_attributes(validations, type).join(', '),
                         value: inclusion_requirement_message(validations) })
      end
      inclusion.presence
    end

    private

    def klass_validator(validation_class, type)
      type.validators.map do |validations|
        affected_attributes(validations, type) if validation_class == validations.class
      end.flatten.compact
    end

    def validation_messages_presence(type)
      presence = { message: 'These columns must have a value: ', value: [] }

      presence[:value] = klass_validator(ActiveRecord::Validations::PresenceValidator, type)
      presence unless presence[:value].empty?
    end

    def validation_messages_numericality(type)
      numericality = { message: 'These columns can only contain numeric values: ', value: [] }

      numericality[:value] = klass_validator(ActiveModel::Validations::NumericalityValidator, type)

      numericality unless numericality[:value].empty?
    end

    def validation_messages_uniqueness(type)
      uniqueness = { message: 'These columns should contain unique values: ', value: [] }

      uniqueness[:value] = klass_validator(ActiveRecord::Validations::UniquenessValidator, type)

      uniqueness unless uniqueness[:value].empty?
    end

    def affected_attributes(validations, type)
      validations.attributes
                 .map { |column| csv_column_name(column, type).to_s }
                 .select(&:present?) # derive_dependent_columns or columns not in CSV_CONVERTER_INFO will be blank
    end

    def csv_column_name(column, type)
      name = type::CSV_CONVERTER_INFO.select { |_k, v| v[:column] == column }.keys.join(', ')
      Common::Shared.display_csv_header(name)
    end

    def inclusion_requirement_message(validations)
      validations.options[:in].map(&:to_s)
    end
  end
end
