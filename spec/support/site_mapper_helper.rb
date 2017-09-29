# frozen_string_literal: true

module SiteMapperHelper
  # Silences output for specs that log to console
  def self.silence
    @stderr = $stderr
    @stdout = $stdout

    # Redirect stderr and stdout
    $stderr = $stdout = StringIO.new

    yield

    $stderr = @stderr
    $stdout = @stdout

    @stderr = nil
    @stdout = nil
  end
end
