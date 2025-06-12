# frozen_string_literal: true

module Common
  # rubocop:disable Metrics/ModuleLength
  module Exporter
    def export
      generate(csv_headers)
    end

    def export_by_version(export_all)
      # every other model uses csv_headers. We don't want to muck that up for them.
      if export_all
        generate_version(csv_headers_for_all_institution_columns)
      else
        generate_version(csv_headers)
      end
    end

    # simple version that takes incoming array of arrays and creates a CSV object with it
    def generate_csv(rows)
      CSV.generate(col_sep: defaults[:col_sep]) do |csv|
        rows.each { |row| csv << row }
      end
    end

    def export_ungeocodables(ungeocodables)
      ungeocodables.prepend(
        ['Institution', 'Facility Code', 'Address 1', 'Address 2', 'Address 3', 'City', 'State',
         'Zip', 'Country', 'IPED', 'OPE']
      )
      generate_csv(ungeocodables)
    end

    def export_unaccrediteds(unaccrediteds)
      unaccrediteds.prepend(['Institution Name', 'Facility Code', 'OPE', 'Agency Name', 'AR End Date'])
      generate_csv(unaccrediteds)
    end

    # Using format_ope for numeric values to preserve leading zeros
    def export_partials(partials)
      partials.each do |p|
        [4, 6, 8].each { |ii| p[ii] = format_ope(p[ii]) }
      end

      partials.prepend(
        ['# GI Bill Students', 'Institution Name', 'Facility code', 'Weams IPEDS', 'Weams OPE', 'Ipeds IPEDS',
         'Ipeds OPE', 'Crosswalk IPEDS', 'Crosswalk OPE']
      )
      generate_csv(partials)
    end

    # Using format_ope for numeric values to preserve leading zeros
    def export_orphans(orphans)
      orphans_array = []
      orphans.each do |o|
        orphans_array << [
          o.institution, o.addr, o.city, o.state, o.zip, format_ope(o.ipeds), format_ope(o.ope),
          format_ope(o.facility_code), o.match_type
        ]
      end

      orphans_array.prepend(
        ['Institution Name', 'Address', 'City', 'State', 'Zip', 'IPEDS', 'OPE', 'Facility Cd', 'Match Type']
      )

      generate_csv(orphans_array)
    end

    private

    def defaults
      Common::Shared.file_type_defaults(klass.name)
    end

    def csv_headers
      csv_headers = {}

      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        key = info[:column]
        csv_headers[key] = Common::Shared.display_csv_header(csv_column)
      end

      csv_headers
    end

    def csv_headers_for_all_institution_columns
      csv_headers = {}

      klass::CSV_CONVERTER_INFO2.each_pair do |csv_column, info|
        key = info[:column]
        csv_headers[key] = Common::Shared.display_csv_header(csv_column)
      end

      csv_headers
    end

    def generate(csv_headers)
      CSV.generate(col_sep: defaults[:col_sep]) do |csv|
        csv << csv_headers.values

        klass == write_row(csv, csv_headers)
      end
    end

    def generate_version(csv_headers)
      CSV.generate(col_sep: defaults[:col_sep]) do |csv|
        csv << csv_headers.values

        klass == write_versioned_row(csv, csv_headers)
      end
    end

    def write_row(csv, csv_headers)
      klass.find_each(batch_size: Settings.active_record.batch_size.find_each) do |record|
        csv << csv_headers.keys.map { |k| format(k, record.public_send(k)) }
      end
    end

    def write_versioned_row(csv, csv_headers)
      raise(MissingAttributeError, "#{klass.name} is not versioned") unless klass.has_attribute?('version_id')

      klass.includes(:version)
           .find_each(batch_size: Settings.active_record.batch_size.find_each) do |record|
        csv << csv_headers.keys.map { |k| record.respond_to?(k) == false ? nil : format(k, record.public_send(k)) }
      end
    end

    def format(key, value)
      return value if value.blank?

      # Should case list grow, a more dynamic approach to deconversion could be implemented
      case key
      when :ope
        "\"#{value}\""
      when :version
        value.number
      when :ojt_app_type
        Converters::OjtAppTypeConverter.deconvert(value)
      end
    end

    def format_ope(col)
      "=\"#{col}\""
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
