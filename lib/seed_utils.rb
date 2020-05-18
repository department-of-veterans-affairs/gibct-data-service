# frozen_string_literal: true

module SeedUtils
  module_function

  def seed_table_with_upload(klass, user, options = {})
    # Pull the default CSV options to be used
    default_options = Rails.application.config.csv_defaults[klass.name] ||
                      Rails.application.config.csv_defaults['generic']
    # Merge with provided options
    seed_options = default_options.transform_keys(&:to_sym).merge(options)

    csv_type = klass.name
    csv_name = "#{csv_type.underscore}.csv"
    csv_path = 'sample_csvs'

    puts "Loading #{klass.name} from #{csv_path}/#{csv_name} ... "

    uf = ActionDispatch::Http::UploadedFile.new(
      tempfile: File.new(Rails.root.join(csv_path, csv_name)),
      # dup required until upgrade: https://github.com/rails/rails/commit/bfbbb1207930e7ebe56d4a99abd53b2aa66e0b6e
      filename: csv_name.dup,
      content_type: 'text/csv'
    )

    upload = Upload.create(upload_file: uf, csv_type: csv_type, comment: 'Seeding', user: user)
    seed_table(klass, "#{csv_path}/#{csv_name}", seed_options)
    upload.update(ok: true)

    puts "Loading #{klass.name} storage from #{csv_path}/#{csv_name} ... "
    uf.rewind

    Storage.create(upload_file: uf, csv_type: csv_type, comment: 'Seeding', user: user)

    puts 'Done!'
  end

  def seed_table(klass, path, options = {})
    klass.load(path, options)
  end
end
