# frozen_string_literal: true

class Converters::NumberConverter < Converters::BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.gsub(/[$,+]/, '')
  end

  # InstitutionArchive#version returns Version record on export, extract number attribute from record
  def self.deconvert(value)
    return value unless value.is_a?(Version)
    
    value.number
  end
end
