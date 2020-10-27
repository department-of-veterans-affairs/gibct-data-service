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
      data = load_file
      alert_messages(data)
      data_results = data[:results]

      binding.pry
      @group.update(ok: data_results.present? && data_results.ids.present?, completed_at: Time.now.utc.to_s(:db))
      error_msg = "There was no saved #{data[:klass]} data. Please check the file or selected options."
      raise(StandardError, error_msg) unless @group.ok?

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
    @group = Group.new(csv_type: group_type)
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
      requirements: requirements_messages(type),
      custom_batch_validator: "#{type.name}Validator::REQUIREMENT_DESCRIPTIONS".safe_constantize,
      inclusion: validation_messages_inclusion(type) }
  end

  def alert_messages(data)
    results = data[:results]

    total_rows_count = results.ids.length
    failed_rows = results.failed_instances
    failed_rows_count = failed_rows.length
    valid_rows = total_rows_count - failed_rows_count
    validation_warnings = failed_rows.sort { |a, b| a.errors[:row].first.to_i <=> b.errors[:row].first.to_i }
                                     .map(&:display_errors_with_row)
    header_warnings = data[:header_warnings]

    if valid_rows.positive?
      flash[:group_success] = {
        total_rows_count: total_rows_count.to_s,
        valid_rows: valid_rows.to_s,
        failed_rows_count: failed_rows_count.to_s
      }.compact
    end

    flash[:warning] = {
      'The following headers should be checked: ': (header_warnings unless header_warnings.empty?),
      'The following rows should be checked: ': (validation_warnings unless validation_warnings.empty?)
    }.compact
  end

  def original_filename
    @original_filename ||= group_params[:upload_file].try(:original_filename)
  end

  def merged_params
    group_params.merge(csv: original_filename, user: current_user)
  end

  def group_params
    @group_params ||= params.require(:group).permit(:csv_type, :upload_file, :comment,
                                                    sheet_type_list: [], skip_lines: [])
  end

  def load_file
    return unless @group.persisted?

    file = @group.upload_file.tempfile

    CrosswalkIssue.delete_all if crosswalk_action?

    data = Group.load_with_roo(file, file_options).first

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

  def requirements_messages(type)
    [validation_messages_presence(type),
     validation_messages_numericality(type),
     validation_messages_uniqueness(type)]
      .compact
  end

  def klass_validator(validation_class, type)
    type.validators.map do |validations|
      affected_attributes(validations, type) if validation_class == validations.class
    end.flatten.compact
  end

  def validation_messages_presence(type)
    presence = { message: 'These columns must have a value: ', value: [] }

    presence[:value] = klass_validator(ActiveRecord::Validations::PresenceValidator, type)
    presence unless presence[:value].empty?
  end

  def validation_messages_numericality(type)
    numericality = { message: 'These columns can only contain numeric values: ', value: [] }

    numericality[:value] = klass_validator(ActiveModel::Validations::NumericalityValidator, type)

    numericality unless numericality[:value].empty?
  end

  def validation_messages_uniqueness(type)
    uniqueness = { message: 'These columns should contain unique values: ', value: [] }

    uniqueness[:value] = klass_validator(ActiveRecord::Validations::UniquenessValidator, type)

    uniqueness unless uniqueness[:value].empty?
  end

  def validation_messages_inclusion(type)
    inclusion = []

    type.validators.map do |validations|
      next unless validations.class == ActiveModel::Validations::InclusionValidator

      array = { message: affected_attributes(validations, type).join(', '),
                value: inclusion_requirement_message(validations) }
      inclusion.push(array)
    end
    inclusion unless inclusion.empty?
  end

  def affected_attributes(validations, type)
    validations.attributes
               .map { |column| csv_column_name(column, type).to_s }
               .select(&:present?) # derive_dependent_columns or columns not in CSV_CONVERTER_INFO will be blank
  end

  def csv_column_name(column, type)
    name = type::CSV_CONVERTER_INFO.select { |_k, v| v[:column] == column }.keys.join(', ')
    Common::Shared.display_csv_header(name)
  end

  def inclusion_requirement_message(validations)
    validations.options[:in].map(&:to_s)
  end
end
