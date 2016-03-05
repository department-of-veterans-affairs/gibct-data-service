###############################################################################
## Preloads all sti classes in development, rather than lazy loading. The 
## parent class needs to recognize its children ASAP. (mph)
###############################################################################
if Rails.env.development? || Rails.env.test?
	# TODO: (mph) Preload all raw file subclasses	
  %w[raw_file school_file weams_file].each do |c|
		require_dependency Rails.root.join("app", "models/raw_files/#{c}.rb")
  end
end