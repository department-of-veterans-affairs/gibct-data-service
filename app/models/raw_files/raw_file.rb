require 'csv'

class RawFile < ActiveRecord::Base
	attr_accessor :upload

	belongs_to :raw_file_source, inverse_of: :raw_files

	validates :name, :upload_date, :type, :raw_file_source_id, presence: true

	#############################################################################
	## inherited
	## Patch for ActionPack in url generating methods that use AR instances.
	## For example, form_for @some_record. This method overrides the model_name
	## method for subclasses to return the base class (RawFile) name so that
	## only one controller is required to handle all STI, so that form_for, 
	## link_to, and so on all refer tho the RawFile controller, regardless of 
	## subtype ... (mph)
	#############################################################################
	def self.inherited(child)
  	child.instance_eval do
    	def model_name
      	RawFile.model_name
    	end
  	end

  	super	
	end

	#############################################################################
	## types
	## Creates a collection for every defined subtype (WeamsFile, Crosswalk, 
	## ...). However, this (and for other reasons) require that STI subclasses
	## are preloaded in the development environment rather than lazy loaded. A
	## Parent class is not aware of a child until that child is loaded. (mph)
	##
	## c.f. /config/initializers/preload_sti_models.rb
	#############################################################################
	def self.types
  	descendants.map do |rf| 
  		[rf.to_s.underscore.split('_').map(&:capitalize).join(' '), rf.to_s] 
  	end
	end

	#############################################################################
	## class_to_source
	## Converts the class name into the name its corresponding file file source.
	#############################################################################
	def class_to_source
		self.class.name.underscore
	end

	#############################################################################
	## to_server_name
	## Builds the name of the raw file on the server by combining the timestamp
	## and raw file source name.
	#############################################################################
	def to_server_name
		server_name = ""
		server_name += upload_date.strftime("%y%m%d%H%M%S%L") if upload_date.present?
		server_name += "_#{class_to_source}.csv" 
	end
end
