# frozen_string_literal: true

# Checks and converts states and protectorates to standardized abbreviations.
class StateConverter < BaseConverter
  STATES = {
    'AK' => 'ALASKA', 'AL' => 'ALABAMA', 'AR' => 'ARKANSAS', 'AS' => 'AMERICAN SAMOA', 'AZ' => 'ARIZONA',
    'CA' => 'CALIFORNIA', 'CO' => 'COLORADO', 'CT' => 'CONNECTICUT',
    'DC' => 'DISTRICT OF COLUMBIA', 'DE' => 'DELEWARE',
    'FL' => 'FLORIDA', 'FM' => 'FEDERATED STATES OF MICRONESIA',
    'GA' => 'GEORGIA', 'GU' => 'GUAM', 'HI' => 'HAWAII',
    'IA' => 'IOWA', 'ID' => 'IDAHO', 'IDN' => 'INDONESIA', 'IL' => 'ILLINOIS', 'IN' => 'INDIANA',
    'KS' => 'KANSAS', 'KY' => 'KENTUCKY',
    'LA' => 'LOUISIANA',
    'MA' => 'MASSACHUSETTS', 'MD' => 'MARYLAND', 'ME' => 'MAINE', 'MH' => 'MARSHALL ISLANDS',
    'MI' => 'MICHIGAN', 'MN' => 'MINNESOTA', 'MO' => 'MISSOURI', 'MP' => 'NORTHERN MARIANA ISLANDS',
    'MS' => 'MISSISSIPPI', 'MT' => 'MONTANA',
    'NC' => 'NORTH CAR', 'ND' => 'NORTH DAKOTA',
    'NE' => 'NEBRASKA', 'NH' => 'NEW HAMPSHIRE', 'NJ' => 'NEW JERSEY',
    'NM' => 'NEW MEXICO', 'NV' => 'NEVADA', 'NY' => 'NEW YORK',
    'OH' => 'OHIO', 'OK' => 'OKLAHOMA', 'OR' => 'OREGON',
    'PA' => 'PENNSYLVANNIA', 'PR' => 'PUERTO RICO', 'PW' => 'PALAU',
    'RI' => 'RHODE ISLAND',
    'SC' => 'SOUTH CAROLINA', 'SD' => 'SOUTH DAKOTA',
    'TN' => 'TENNESSEE', 'TX' => 'TEXAS',
    'UT' => 'UTAH',
    'VA' => 'VIRGINIA', 'VI' => 'VIRGIN ISLANDS', 'VT' => 'VERMONT',
    'WA' => 'WASHINGTON', 'WI' => 'WISCONSIN',
    'WV' => 'WEST VIRGINA',
    'WY' => 'WYOMING'
  }.freeze

  def self.convert(value)
    value = super(value)
    return nil if value.blank?

    value = value.upcase
    STATES.key?(value) ? value : STATES.key(value)
  end
end
