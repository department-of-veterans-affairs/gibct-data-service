# frozen_string_literal: true

require 'fileutils'

SUFFIXES = {
  'c' => 'dump',
  'd' => 'dir',
  'p' => 'sql',
  't' => 'tar'
}.freeze

# rubocop:disable Metrics/BlockLength
namespace :db do
  desc 'Vacuum and Analyze Institution tables used in generating previews'
  task vac_and_analyze_prev_tables: :environment do
    DbCleanup.vacuum_and_analyze_preview_tables
  end

  desc 'Delete a broken preview'
  task :delete_broken_preview, [:version_id] => :environment do |_t, args|
    DbCleanup.delete_broken_preview(args.version_id)
  end

  desc 'Dumps the database to backups'
  task dump: :environment do
    dump_fmt = 'c' # or 'p', 't', 'd'
    dump_sfx = suffix_for_format dump_fmt
    backup_dir = backup_directory true
    cmd = nil
    with_config do |_app, host, db, _user|
      file_name = Time.current.strftime('%Y%m%d%H%M%S') + '_' + db + '.' + dump_sfx
      cmd = "pg_dump -F #{dump_fmt} -v -h #{host} -d #{db} -f #{backup_dir}/#{file_name}"
    end
    puts cmd
    exec cmd
  end

  desc 'Show the existing database backups'
  task list: :environment do
    backup_dir = backup_directory
    puts backup_dir
    exec "/bin/ls -lt #{backup_dir}"
  end

  desc 'Restores the database from a backup using PATTERN'
  task :restore, [:pat] => :environment do |_task, args|
    if args.pat.present?
      cmd = nil
      with_config do |_app, _host, _db, _user|
        backup_dir = backup_directory
        files = Dir.glob("#{backup_dir}/*#{args.pat}*")
        case files.size
        when 0
          puts "No backups found for the pattern '#{args.pat}'"
        when 1
          file = files.first
          fmt = format_for_file file
          if fmt.nil?
            puts "No recognized dump file suffix: #{file}"
          else
            cmd = "pg_restore -F #{fmt} -v -c -C #{file}"
          end
        else
          puts "Too many files match the pattern '#{args.pat}':"
          puts ' ' + files.join("\n ")
          puts 'Try a more specific pattern'
        end
      end
      unless cmd.nil?
        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        puts cmd
        exec cmd
      end
    else
      puts 'Please pass a pattern to the task'
    end
  end

  private

  def suffix_for_format(suffix)
    SUFFIXES[suffix]
  end

  def format_for_file(file)
    case file
    when /\.dump$/ then 'c'
    when /\.sql$/  then 'p'
    when /\.dir$/  then 'd'
    when /\.tar$/  then 't'
    end
  end

  def backup_directory(create = false)
    backup_dir = Rails.root.join('db', 'backups')
    if create && !Dir.exist?(backup_dir)
      puts "Creating #{backup_dir} .."
      FileUtils.mkdir_p(backup_dir)
    end
    backup_dir
  end

  def with_config
    yield Rails.application.class.parent_name.underscore,
          (ActiveRecord::Base.connection_config[:host] || 'localhost'),
          ActiveRecord::Base.connection_config[:database],
          ActiveRecord::Base.connection_config[:username]
  end

  # rubocop:enable Metrics/BlockLength
end
