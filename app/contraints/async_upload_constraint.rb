# frozen_string_literal: true

class AsyncUploadConstraint
  def initialize(async_enabled:)
    @async_enabled = async_enabled
  end

  # Conditional routing based on whether async enabled
  def matches?(request)
    async_setting = if request.params.dig(:upload, :csv_type)
                      settings_from_csv_type(request.params)
                    else
                      settings_from_upload_id(request.params)
                    end
    async_setting == @async_enabled
  end

  private

  # Check if async enabled for new upload determined by csv file type defaults
  def settings_from_csv_type(params)
    csv_type = params[:upload][:csv_type]
    settings = Common::Shared.file_type_defaults(csv_type)[:async_upload].transform_keys(&:to_sym)
    settings[:enabled]
  end

  # Check if async enabled for an existing upload
  def settings_from_upload_id(params)
    upload = Upload.find_by(id: params[:id])
    upload.async_enabled?
  end
end
