###############################################################################
## The Standardizable module ensures the uniformity of fields accross the 
## multiple CSVs that comprise the data. A special class method called
## override_setters takes an array argument of field names, and ensures that
## the values written to the instance are uniform (e.g, all the same case, the
## string values that can represent true and false are converted in a
## in a centralized manner, specific fields are padded, and so on). It also
## provides a case insensitive matcher.
###############################################################################
module Standardizable
  extend ActiveSupport::Concern

  class_methods do
    ###########################################################################
    ## forbidden_word
    ## Identifies those words that are present in some CSVs that represent 
    ## null values, but for some reason are included in the soruce CSV.
    ###########################################################################
    def forbidden_word?(v)
      ['none', 'null', 'privacysuppressed'].include?(v.try(:downcase))
    end

    ###########################################################################
    ## truthy?
    ## Converts string "truths" to boolean truths.
    ###########################################################################
    def truthy?(v)
      ["true", "t", "yes", "ye", "y", "1", "on"].include?(v.try(:downcase))
    end

    ###########################################################################
    ## override_setters
    ## Rewrites setters in an attempt to standardize data input from csvs.
    ###########################################################################
    def override_setters(*setters)
      setters.each do |setter|
        case setter

        #######################################################################
        ## facility_code
        #######################################################################
        when :facility_code
          define_method(:facility_code=) do |v|
            write_attribute(:facility_code, v.strip.upcase) if v.present?
          end

        #######################################################################
        ## institution
        #######################################################################
        when :institution
          define_method(:institution=) do |v|
            if v.present?
              v = v.to_s.gsub("'", "''").strip.try(:upcase)
              write_attribute(:institution, v) 
            end
          end

        #######################################################################
        ## ope6
        #######################################################################
        when :ope6
          define_method(:ope6=) do |v|            
            if v.present? && !self.class.forbidden_word?(v.downcase)
              write_attribute(:ope6, self.class.pad(v.strip, 8)[1, 5]) 
            end
          end 

        #######################################################################
        ## ope
        #######################################################################
        when :ope
          define_method(:ope=) do |v|
            v = v.try(:strip).try(:upcase) if v.is_a?(String)
            v = nil if self.class.forbidden_word?(v)

            write_attribute(:ope, self.class.pad(v, 8)) 
            self.ope6 = ope
          end   
                 
        #######################################################################
        ## state
        #######################################################################
        when :state
          define_method(:state=) do |v|
            write_attribute(:state, DS::State.get_abbr(v.strip)) if v.present?
          end

        #######################################################################
        ## miscellaneous
        #######################################################################
        else
          define_method("#{setter.to_s}=".to_sym) do |v|
            col = self.class.columns.find { |col| col.name == setter.to_s }

            if v.is_a?(String)
              v = v.try(:strip)
              v = nil if self.class.forbidden_word?(v) || v.blank?
              v = v.to_s.gsub("'", "''") if !v.nil?
            end

            if col.try(:sql_type) == "boolean"
              if !v.nil?
                v = self.class.truthy?(v) if v.is_a?(String)
                write_attribute(setter, v)
              end
            else
              write_attribute(setter, v)              
            end
          end
        end
      end
    end

    ###########################################################################
    ## fields
    ## Gets a list of fields recognized by the model.
    ###########################################################################
    def fields
      column_names.map(&:to_sym)
        .reject { |c| [:id, :created_at, :updated_at].include? c }
    end

    ###########################################################################
    ## pad
    ## Left-justifies text v in a field padded by l characters c.
    ###########################################################################
    def pad(v, l, c = '0')
      v.ljust(l, c)  if v.present? && v.class == String && v.downcase != 'none'
    end

    ###########################################################################
    ## match
    ## Performs a case insensitive string match if the pattern is a string, or
    ## a match if the pattern is a regex.
    ###########################################################################
    def match(pattern, value)
      return false if value.blank? || pattern.blank?

      if pattern.is_a?(String)
        m = (value =~ Regexp.new(pattern, true)) != nil
      elsif pattern.is_a?(Regexp)
        m = (value =~ pattern) != nil
      end
    end
  end
end