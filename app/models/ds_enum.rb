module DS_ENUM
  #############################################################################
  ## Truth
  ## Normalalize truth values accross csvs.
  #############################################################################
  class Truth
    TRUTHS = %w(Y y Yes yes True true T t 1 YES)

    ###########################################################################
    ## truthy?
    ## Returns true if value is a truthy value (converts to true).
    ###########################################################################
    def self.truthy?(value)
      TRUTHS.include?(value)
    end

    ###########################################################################
    ## yes
    ## Normalizes a string truth value to yes
    ###########################################################################
    def self.yes
      "yes"
    end


    ###########################################################################
    ## yes
    ## Normalizes a string false value to no
    ###########################################################################
    def self.no
      "no"
    end

    ###########################################################################
    ## value_to_truth
    ## Normalizes a string.
    ###########################################################################
    def self.value_to_truth(value)
      truthy?(value) ? yes : no
    end 
  end

  #############################################################################
  ## State
  ## Handles collection of states, normalizes states.
  #############################################################################
  class State
    STATES = { 
      "AK" => "Alaska", "AL" => "Alabama", "AR" => "Arkansas", 
      "AS" => "American Samoa", "AZ" => "Arizona",
      "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut",
      "DC" => "District of Columbia", "DE" => "Delaware", 
      "FL" => "Florida", "FM" => "Federated States of Miconeisa",
      "GA" => "Georgia", "GU" => "Guam",
      "HI" => "Hawaii",
      "IA" => "Iowa", "ID" => "Idaho", "IL" => "Illinois", "IN" => "Indiana",
      "KS" => "Kansas", "KY" => "Kentucky",
      "LA" => "Louisiana",
      "MA" => "Massachusetts", "MD" => "Maryland", "ME" => "Maine", "MH" => "Marshall Islands",
      "MI" => "Michigan", "MN" => "Minnesota", "MO" => "Missouri", "MP" => "Northern Mariana Islands",
      "MS" => "Mississippi", "MT" => "Montana",
      "NC" => "North Carolina", "ND" => "North Dakota",
      "NE" => "Nebraska", "NH" => "New Hampshire", "NJ" => "New Jersey",
      "NM" => "New Mexico", "NV" => "Nevada", "NY" => "New York",
      "OH" => "Ohio", "OK" => "Oklahoma", "OR" => "Oregon",
      "PA" => "Pennsylvania", "PR" => "Puerto Rico", "PW" => "Palau",
      "RI" => "Rhode Island", 
      "SC" => "South Carolina", "SD" => "South Dakota",
      "TN" => "Tennessee", "TX" => "Texas",
      "UT" => "Utah",
      "VA" => "Virginia", "VI" => "Virgin Islands", "VT" => "Vermont",
      "WA" => "Washington", "WI" => "Wisconsin",
      "WV" => "West Virginia",
      "WY" => "Wyoming"
    }

    ###########################################################################
    ## get_random_state
    ## Returns a randomly selected state_abbreviation => state_full_name
    ###########################################################################
    def self.get_random_state
      s = STATES.keys.sample
      { s => STATES[s] }
    end

    ###########################################################################
    ## []
    ## Returns the  name corresponding to the state name (abbreviation or
    ## full name).
    ###########################################################################
    def self.[](state_name)
      STATES[state_name] || STATES.key(state_name)
    end

    ###########################################################################
    ## get_names
    ## Gets a list of state name abbreviations.
    ###########################################################################
    def self.get_names
      STATES.keys
    end

    ###########################################################################
    ## get_full_names
    ## Gets a list of full state names.
    ###########################################################################
    def self.get_full_names
      STATES.values
    end

    ###########################################################################
    ## get_as_options
    ## Gets a list of states in a form suitable of selects.
    ###########################################################################
    def self.get_as_options
      STATES.map { |name, full_name| [full_name, name] }
    end
  end
end