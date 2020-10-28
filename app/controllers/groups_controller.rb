# frozen_string_literal: true

#
# This should not have to be here but ruby is not loading this in config/initializers/roo_helper.rb
Dir["#{Rails.application.config.root}/lib/roo_helper/**/*.rb"].sort.each { |f| require(f) }

class GroupsController < ApplicationController
  def new
    return if setup(params[:group_type])

    alert_and_log(@group.errors.full_messages.join(', '))
    redirect_to dashboards_path
  end

  def create
    @group = Group.create(merged_params)
    begin
      loaded_data = load_file
      alert_messages(loaded_data)
      validate(loaded_data)

      redirect_to @group
    rescue StandardError => e
      setup(merged_params[:csv_type])
      alert_and_log("Failed to upload #{original_filename}: #{e.message}\n#{e.backtrace[0]}", e)
      render :new
    end
  end

  def show
    @group = Group.find_by(id: params[:id])
    @group.group_config = Group.group_config_options(@group.csv_type)

    return requirements if @group.present?

    alert_and_log("Upload with id: '#{params[:id]}' not found")
    redirect_to uploads_path
  end

  private

  def setup(group_type)
    @group = Group.create_from_group_type(csv_type: group_type)
    @extensions = Settings.roo_upload.extensions.group.join(', ')
    @sheets = @group.sheet_names
    requirements if @group.csv_type_check?

    @group.csv_type_check?
  end

  # Build array of requirements information based on what types are in the group
  def requirements
    @requirements = []
    @group.sheets.each do |type|
      @requirements << upload_requirements(type)
    end
  end

  def upload_requirements(type)
    { type: type.name,
      requirements: UploadRequirements.requirements_messages(type),
      custom_batch_validator: "#{type.name}Validator::REQUIREMENT_DESCRIPTIONS".safe_constantize,
      inclusion: UploadRequirements.validation_messages_inclusion(type) }
  end

  def alert_messages(loaded_data)
    flash[:group_success] = {}
    flash[:warning] = {}

    loaded_data.each do |data|
      loaded_data = data[:results]
      data_klass = data[:klass].name
      header_warnings = data[:header_warnings]

      success_message(loaded_data, data_klass)
      warning_message(loaded_data, data_klass, header_warnings)
    end

    flash[:group_success].compact
    flash[:warning].compact
  end

  def success_message(loaded_data, data_klass)
    total_rows_count = loaded_data.ids.length
    failed_rows = loaded_data.failed_instances
    failed_rows_count = failed_rows.length
    valid_rows = total_rows_count - failed_rows_count

    if valid_rows.positive?
      flash[:group_success][data_klass] = {
        total_rows_count: total_rows_count.to_s,
        valid_rows: valid_rows.to_s,
        failed_rows_count: failed_rows_count.to_s
      }.compact
    end
  end

  def warning_message(loaded_data, data_klass, header_warnings)
    failed_rows = loaded_data.failed_instances

    validation_warnings = failed_rows.sort { |a, b| a.errors[:row].first.to_i <=> b.errors[:row].first.to_i }
                                     .map(&:display_errors_with_row)

    return unless header_warnings.any? || validation_warnings.any?

    flash[:warning][data_klass] = {
      'The following headers should be checked: ': (header_warnings unless header_warnings.empty?),
      'The following rows should be checked: ': (validation_warnings unless validation_warnings.empty?)
    }.compact
  end

  # if any sheet uploads successfully then consider upload a success
  # For sheets that failed to upload append to the upload's comment that they failed and raise an error
  def validate(loaded_data)
    ok = loaded_data.any? { |data| data[:results].present? && data[:results].ids.present? }
    no_saved_data = loaded_data.select { |data| data[:results].blank? || data[:results].ids.blank? }
                               .map { |data| data[:klass].name }
    error_msg = @group.comment + " There was no saved #{no_saved_data.join(', or ')} data."

    @group.update(ok: ok, completed_at: Time.now.utc.to_s(:db), comment: (error_msg unless no_saved_data.none?))

    raise(StandardError, error_msg + ' Please check the file or selected options.') unless no_saved_data.none?
  end

  def original_filename
    @original_filename ||= group_params[:upload_file].try(:original_filename)
  end

  def merged_params
    group_params[:parse_as_xml] = BooleanConverter.convert(group_params[:parse_as_xml])
    group_params.merge(csv: original_filename, user: current_user)
  end

  def group_params
    @group_params ||= params.require(:group).permit(:csv_type, :upload_file, :comment, :parse_as_xml,
                                                    sheet_type_list: [], skip_lines: [])
  end

  def load_file
    return unless @group.persisted?

    file = @group.upload_file.tempfile

    CrosswalkIssue.delete_all if crosswalk_action?

    data = Group.load_with_roo(file, file_options)

    CrosswalkIssue.rebuild if crosswalk_action?

    data
  end

  # Set options for using RooHelper::Loader
  def file_options
    sheets = []
    @group.sheet_type_list.each_with_index do |sheet_type, index|
      sheets << {
        klass: sheet_type.constantize,
        skip_lines: @group.skip_lines[index].to_i
      }
    end
    { parse_as_xml: @group.parse_as_xml,
      sheets: sheets }
  end

  # delete and rebuild if the intersection of selected File Types array and
  # [Crosswalk, IpedsHd, Weam]
  def crosswalk_action?
    ([Crosswalk, IpedsHd, Weam] & @group.sheet_type_list.map(&:constantize)).any?
  end
end
