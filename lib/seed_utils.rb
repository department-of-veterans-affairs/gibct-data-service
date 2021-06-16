# frozen_string_literal: true

module SeedUtils
  module_function

  def seed_tables_with_group(group, user, options = {})
    group_options = Group.group_config_options(group)
    sheets = []
    group_options[:types].each do |type|
      sheets << {
        klass: type,
        skip_lines: 0
      }
    end

    file_options = { sheets: sheets }
    xlxs_name = "#{group}.xlsx"

    load_table(Group, user, file_options.reverse_merge(options),
               xlxs_name, group, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
  end

  def seed_table_with_upload(klass, user, options = {}, file_ext = 'csv')
    seed_options = Common::Shared.file_type_defaults(klass.name, options)
    file_options = { liberal_parsing: seed_options[:liberal_parsing],
                     sheets: [{ klass: klass, skip_lines: seed_options[:skip_lines].try(:to_i) },
                              clean_rows: seed_options[:clean_rows] ] }

    csv_type = klass.name
    csv_name = "#{csv_type.underscore}.#{file_ext}"
    content_type = if file_ext == 'xlsx'
                     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                   else
                     'text/csv'
                   end

    load_table(klass, user, file_options, csv_name, csv_type, content_type)
  end

  def load_table(klass, user, file_options, file_name, file_type, content_type)
    file_path = 'sample_csvs'

    puts "Loading #{klass.name} from #{file_path}/#{file_name} ... "

    uf = ActionDispatch::Http::UploadedFile.new(
      tempfile: File.new(Rails.root.join(file_path, file_name)),
      # dup required until upgrade: https://github.com/rails/rails/commit/bfbbb1207930e7ebe56d4a99abd53b2aa66e0b6e
      filename: file_name.dup,
      content_type: content_type
    )

    upload = Group.create(upload_file: uf, csv_type: file_type, comment: 'Seeding', user: user)
    seed_table(klass, "#{file_path}/#{file_name}", file_options)
    upload.update(ok: true)

    puts "Loading #{klass.name} storage from #{file_path}/#{file_name} ... "
    uf.rewind

    Storage.create(upload_file: uf, csv_type: file_type, comment: 'Seeding', user: user)

    puts 'Done!'
  end

  def seed_table(klass, path, options = {})
    klass.load_with_roo(path, options)
  end
end
