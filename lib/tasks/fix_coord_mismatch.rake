# frozen_string_literal: true

desc 'task to update any mistmached coordinates with geocoder gem.'
task fix_coord_mismatch: :environment do
  version = Version.current_preview
  search_geocoder = SearchGeocoder.new(version) if version.present? && version.geocoded == false
  search_geocoder.process_geocoder_address if search_geocoder.by_address.present?
end
