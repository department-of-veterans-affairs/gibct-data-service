module Alertable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    ###########################################################################
    ## pretty_error
    ## Wraps an array of messages (presumably errors) in a list.
    ###########################################################################
    def pretty_error(label = '', errors = [])
      msg = errors.inject('<ul>') do |m, error|
        m + "<li>#{error}</li>"
      end + '</ul>'

      pstr = ''
      pstr += "<p>#{label}</p>" if label.present?
      pstr += msg if errors.present?

      pstr
    end

    ###########################################################################
    ## get_csv_file_types
    ## Provides a list of all *CsvFile classes, excluding the base CsvFile
    ## class itself.
    ###########################################################################
    def get_csv_file_types
      # Get all but the base class CsvFile
      Module.constants.select { |c| c.to_s =~ /\w+csvfile/i }.map do |csv|
        csv = csv.to_s

        name = csv.underscore.split('_').map(&:capitalize)
                  .join(' ').gsub(/csv file/i, '').strip

        [name, csv]
      end
    end
  end
end
