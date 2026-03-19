require 'ferrum'
require 'fileutils'
require 'base64'

# 1. docker build --target=development -t gibct-dev .                 # build image
# 2. docker compose up                                                # run container
# 3. navigate to new terminal window
# 3a. docker exec -it gibct-data-service-gibct-1 /bin/bash            # enter container
# 4. ruby test_ferrum.rb                                              # run script from in terminal
# 5. ls /tmp/downloads/

DOWNLOAD_DIR = '/tmp/downloads'
FILE_PATH = "#{DOWNLOAD_DIR}/institutions.xlsx"
FileUtils.mkdir_p(DOWNLOAD_DIR)

browser = Ferrum::Browser.new(
  browser_path: '/usr/bin/chromium',
  browser_options: { 'no-sandbox': nil },
  headless: 'new'
)

browser.go_to('https://dhra.appianportalsgov.com/DoD-MOU/page/institutions')
puts "Page title: #{browser.title}"

# Wait for the Export to Excel button to appear
export_button = nil
30.times do
  export_button = browser.at_xpath('//button[.//span[contains(text(), "Export to Excel")]]')
  break if export_button

  sleep 1
end

raise 'Export to Excel button not found after 30 seconds' unless export_button

# Intercept download at the Response stage before Chrome handles it.
page = browser.page
download_complete = false

page.command('Fetch.enable', patterns: [
               { urlPattern: '*download-grid*', requestStage: 'Response' }
             ])
puts 'Fetch interception enabled.'

# Subscribe to the CDP event that fires when a matching response is paused
page.on('Fetch.requestPaused') do |params|
  request_id = params['requestId']
  url = params['request']['url']
  puts "  [FETCH] Paused response for: #{url}"

  begin
    # Retrieve the response body from the paused request
    result = page.command('Fetch.getResponseBody', requestId: request_id)
    body = if result['base64Encoded']
             Base64.decode64(result['body'])
           else
             result['body']
           end

    File.binwrite(FILE_PATH, body)
    puts "  [FETCH] Saved #{body.bytesize} bytes to #{FILE_PATH}"
    download_complete = true
  rescue StandardError => e
    puts "  [FETCH] Error getting body: #{e.message}"
  ensure
    # Let the response continue so the page doesn't hang
    page.command('Fetch.continueResponse', requestId: request_id)
  end
end

# Wait for response to be processed
60.times do |i|
  break if download_complete

  puts "  Waiting for download response... (#{i}s)" if (i % 10).zero?
  sleep 1
end

if download_complete
  puts "Successfully downloaded: #{FILE_PATH}"
else
  puts 'WARNING: Download response not captured within 60 seconds.'
end

browser.quit # verify the download exists
