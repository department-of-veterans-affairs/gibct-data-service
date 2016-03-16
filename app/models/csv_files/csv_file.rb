class CsvFile < ActiveRecord::Base
	attr_accessor :upload

	STI = %W(WeamsCsvFile)
	DELIMITERS = [',', '|', ' ']

	validates :type, inclusion: { in: STI  }

	before_save :set_name, :upload_file, :populate
	before_destroy :clear_data

	#############################################################################
	## last_upload_date
	## Gets the date on which the last file was uploaded
	#############################################################################
	scope :last_upload_date, -> { 
		maximum(:upload_date).in_time_zone('Eastern Time (US & Canada)') 
	}

	#############################################################################
	## last_upload
	## Gets the last uploaded csv.
	#############################################################################
	scope :last_upload, -> { order(:upload_date, :id).last }

	#############################################################################
	## inherited
	## Patch for ActionPack in url generating methods that use AR instances.
	## For example, form_for @some_record. This method overrides the model_name
	## method for subclasses to return the base class (CsvFile) name so that
	## only one controller is required to handle all STI, so that form_for, 
	## link_to, and so on all refer tho the RawFile controller, regardless of 
	## subtype ... (mph)
	#############################################################################
	def self.inherited(child)
  	child.instance_eval do
    	def model_name
      	CsvFile.model_name
    	end
  	end

  	super	
	end

	#############################################################################
	## types
	## Creates a collection for every defined subtype (WeamsCsvile, 
	## CrosswalkCsvFile, ...). However, this (and for other reasons) require 
	## that STI subclasses are preloaded in the development environment rather 
	## than lazy loaded. A Parent class is not aware of a child until that child 
	## is loaded. (mph)
	##
	## c.f. /config/initializers/preload_sti_models.rb
	#############################################################################
	def self.types
  	descendants.map do |csv| 
  		[csv.to_s.underscore.split('_').map(&:capitalize).join(' '), csv.to_s] 
  	end
	end

	#############################################################################
	## class_to_type
	## Converts the class name into the name its corresponding file file type.
	#############################################################################
	def class_to_type
		self.class.name.underscore
	end

	#############################################################################
	## clear_data
	#############################################################################
	def clear_data
		puts "@@@@@@@@@@@@ latest: #{latest?}"
		puts "@@@@@@@@@@@@ instance: #{ upload_date.strftime("%y%m%d%H%M%S%9N") }"
		puts "@@@@@@@@@@@@ class: #{ self.class.last_upload_date.strftime("%y%m%d%H%M%S%9N") }"
		if latest?
			if store = CsvStorage.find_by(csv_file_type: type)
				store.data_store = nil
				store.save!
			end

			Weam.destroy_all
		end
	end

	#############################################################################
	## set_name
	## Builds the name of the raw file on the server by combining the timestamp
	## and csv file type name. If there is not associated csv data storage,
	## storage for the csv type is created.
	#############################################################################
	def set_name
		self.upload_date = DateTime.current

		self.name = upload_date.strftime("%y%m%d%H%M%S%L")
		self.name += "_#{class_to_type}.csv"
	end

	#############################################################################
  ## upload_file
  ## Uploads the given file into the storage data binary.
  #############################################################################  
  def upload_file
  	store = CsvStorage.find_or_create_by(csv_file_type: type)

		old_logger = ActiveRecord::Base.logger
		ActiveRecord::Base.logger = nil

		begin
			# Require an upload file, doesn't make sense to allow updates without.
			raise StandardError.new("No upload file provided.") if upload.blank?

			store.data_store = upload.read
			rc = store.save
  	rescue StandardError => e
  		errors[:base] << e.message
  		rc = false
  	ensure
			ActiveRecord::Base.logger = old_logger  		
 		end

 		return rc
  end

	#############################################################################
	## latest?
	## True if this instance is the last uploaded for its type.
	#############################################################################
	def latest?
		str1 = upload_date.strftime("%y%m%d%H%M%S%9N")
		str2 = self.class.last_upload_date.strftime("%y%m%d%H%M%S%9N")
		str1 == str2
	end

	#############################################################################
	## humanize_date
	## Returns a readable form of the upload date.
	#############################################################################
	def humanize_date
		upload_date.present? ? upload_date.strftime("%B %d, %Y") : '-'
	end

	#############################################################################
	## humanize_type
	## Returns a readable form of the class type.
	#############################################################################
	def humanize_type
		class_to_type.split("_").map(&:capitalize).join(" ")
	end
end
