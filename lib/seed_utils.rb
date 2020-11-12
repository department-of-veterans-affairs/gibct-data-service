# frozen_string_literal: true

module SeedUtils
  module_function

  def seed_tables_with_group(group, user, options)
    group_options = Group.group_config_options(group)
    sheets = []
    group_options[:types].each do |type|
      sheets << {
          klass: type,
          skip_lines: 0
      }
    end
   
    file_options = { sheets: sheets }
    csv_name = "#{group}.xlsx"
    csv_path = 'sample_csvs'

    load_table(Group, user, file_options.reverse_merge(options), csv_name)
    uf = ActionDispatch::Http::UploadedFile.new(
      tempfile: File.new(Rails.root.join(csv_path, csv_name)),
      # dup required until upgrade: https://github.com/rails/rails/commit/bfbbb1207930e7ebe56d4a99abd53b2aa66e0b6e
      filename: csv_name.dup,
      content_type: 'text/xlsx'
    )

    upload = Upload.create(upload_file: uf, csv_type: Group, comment: 'Seeding', user: user)
    seed_table(Group, "#{csv_path}/#{csv_name}", file_options)
    upload.update(ok: true)

    uf.rewind

    Storage.create(upload_file: uf, csv_type: Group, comment: 'Seeding', user: user)
  end

  def seed_table_with_upload(klass, user, options = {})
    seed_options = Common::Shared.file_type_defaults(klass.name, options)
    file_options = { liberal_parsing: seed_options[:liberal_parsing],
                     sheets: [{ klass: klass, skip_lines: seed_options[:skip_lines].try(:to_i) }] }

    csv_type = klass.name
    csv_name = "#{csv_type.underscore}.csv"
    csv_path = 'sample_csvs'

    load_table(klass, user, file_options, csv_name)

    uf = ActionDispatch::Http::UploadedFile.new(
      tempfile: File.new(Rails.root.join(csv_path, csv_name)),
      # dup required until upgrade: https://github.com/rails/rails/commit/bfbbb1207930e7ebe56d4a99abd53b2aa66e0b6e
      filename: csv_name.dup,
      content_type: 'text/csv'
    )

    upload = Upload.create(upload_file: uf, csv_type: csv_type, comment: 'Seeding', user: user)
    seed_table(klass, "#{csv_path}/#{csv_name}", file_options)
    upload.update(ok: true)

    puts "Loading #{klass.name} storage from #{csv_path}/#{csv_name} ... "
    uf.rewind

    Storage.create(upload_file: uf, csv_type: csv_type, comment: 'Seeding', user: user)

    puts 'Done!'
  end

  def load_table(klass, user, file_options, csv_name)
    csv_path = 'sample_csvs'
    puts "Loading #{klass.name} from #{csv_path}/#{csv_name} ... "
  end  
  def seed_table(klass, path, options = {})
    klass.load_with_roo(path, options)
  end
end
