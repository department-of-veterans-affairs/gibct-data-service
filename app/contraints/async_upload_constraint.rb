class AsyncUploadConstraint
  def initialize(async_enabled:)
    @async_enabled = async_enabled
  end

  def matches?(request)
    async_setting = if request.params.dig(:upload, :csv_type)
                      settings_from_csv_type(request.params)
                    else
                      settings_from_upload_id(request.params)
                    end
    async_setting == @async_enabled
  end

  private

  def settings_from_csv_type(params)
    csv_type = params[:upload][:csv_type]
    settings = Common::Shared.file_type_defaults(csv_type)[:async_upload].transform_keys(&:to_sym)
    settings[:enabled]
  end

  def settings_from_upload_id(params)
    upload = Upload.find_by(id: params[:id])
    upload.async_enabled?
  end
end
