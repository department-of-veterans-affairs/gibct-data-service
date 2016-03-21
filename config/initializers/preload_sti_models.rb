##############################################################################
## Preloads all Single Table Inheritance (STI) classes in development, rather 
## than lazy loading. The parent class needs to recognize its children ASAP.
## (mph)
##############################################################################
if Rails.env.development? || Rails.env.test?
	# TODO: (mph) Preload all raw file subclasses	
  %w(
    csv_file weams_csv_file va_crosswalk_csv_file eight_key_csv_file
    scorecard_csv_file
  ).each do |c|
		require_dependency Rails.root.join("app", "models/csv_files/#{c}.rb")
  end
end