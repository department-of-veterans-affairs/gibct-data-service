# frozen_string_literal: true

# Match uploads#post route to action based on async settings for csv type
class UploadConstraint
  def initialize(async_enabled: false)
    @async_enabled = async_enabled
  end

  def matches?(request)
    csv_type = request.params[:upload][:csv_type]
    default_settings = Common::Shared.file_type_defaults(:generic)[:async_upload]
    upload_settings = Common::Shared.file_type_defaults(csv_type)[:async_upload] || default_settings
    @async_enabled == upload_settings["enabled"]
  end
end
