##############################################################################
## Preloads all Single Table Inheritance (STI) classes in development, rather 
## than lazy loading. The parent class needs to recognize its children ASAP.
## (mph)
##############################################################################
if Rails.env.development? || Rails.env.test?
	# TODO: (mph) Preload all raw file subclasses - Weams MUST be last ...	
  %w(
    csv_file accreditation_csv_file arf_gibill_csv_file eight_key_csv_file 
    mou_csv_file p911_tf_csv_file p911_yr_csv_file scorecard_csv_file 
    sec702_school_csv_file sec702_csv_file sva_csv_file va_crosswalk_csv_file 
    vsoc_csv_file weams_csv_file 
  ).each do |c|
		require_dependency Rails.root.join("app", "models/csv_files/#{c}.rb")
  end
end