module Standardizable
  extend ActiveSupport::Concern

  class_methods do
    ###########################################################################
    ## truthy?
    ## Converts string "truths" to boolean truths.
    ###########################################################################
    def truthy?(v)
      ["true", "t", "yes", "ye", "y", "1", "on"].include?(v)
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
            write_attribute(:institution, v.strip) if v.present?
          end

        #######################################################################
        ## ope6
        #######################################################################
        when :ope6
          define_method(:ope6=) do |v|
            if v.present? && v.downcase != "none" && v.downcase != "null"
              write_attribute(:ope6, self.class.pad(v.strip, 8)[1, 5]) 
            end
          end 

        #######################################################################
        ## ope
        #######################################################################
        when :ope
          define_method(:ope=) do |v|
            v = v.try(:strip).try(:downcase) if v.is_a?(String)
            v = nil if v == "none" || v == "null"

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

            v = v.try(:strip).try(:downcase) if v.is_a?(String)
            v = nil if v == "none" || v == "null"

            if col.try(:sql_type) == "boolean"
              v = self.class.truthy?(v) if v.is_a?(String)
              write_attribute(setter, v)
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
  end
end