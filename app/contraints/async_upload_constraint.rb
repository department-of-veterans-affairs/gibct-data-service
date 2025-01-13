class AsyncUploadConstraint
  def initialize(async_enabled:)
    @async_enabled = async_enabled
  end

  def matches?(request)
    csv_type = request.params[:upload][:csv_type]
    async_settings = Common::Shared.file_type_defaults(csv_type)[:async_upload].transform_keys(&:to_sym)
    @async_enabled == async_settings[:enabled]
  end
end
