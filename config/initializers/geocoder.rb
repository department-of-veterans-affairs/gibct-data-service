# The default backend geocoding service is nominatim. At some point in late May 2024,
# the user agent became mandatory and nominatim started returning parse errors to
# the Geocoder gem unless this was provided.
Geocoder.configure(
  http_headers: { "User-Agent" => "Brian.Grubb@va.gov" },
  timeout: 15,
  always_raise: :all
)
