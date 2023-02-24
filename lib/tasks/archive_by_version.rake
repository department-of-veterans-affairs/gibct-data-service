# frozen_string_literal: true

desc 'task to archive institutions and related tables by version'
task :archive_by_version, [:version_id] => [:environment] do |_t, args|
  version_id = args[:version_id]
  archive_version(version_id)
end

def archive_version(version_id)
  ApplicationRecord.transaction do
    timeout = set_timeout_sql || '60000'
    Archiver::ARCHIVE_TYPES.each do |archivable|
      create_archives(archivable[:source], archivable[:archive], version_id)
      source = set_source(archivable)
      puts "deleting from #{archivable[:source]}"
      source.where('versions.id = ?', version_id).in_batches.delete_all
    end
  rescue StandardError => e
    puts "There was an error #{e.message}"
  ensure
    ActiveRecord::Base.connection.execute("SET statement_timeout = #{timeout}")
    get_timeout_sql = "select setting from pg_settings where name = 'statement_timeout'"
    puts 'resetting to default timeout'
    timeout_result = ActiveRecord::Base.connection.execute(get_timeout_sql).first
    puts "default timeout (reset): #{timeout_result['setting']}"
  end
end

def self.create_archives(source, archive, version_id)
  return if archive.blank?

  cols = archive.column_names
  insert_cols = (cols.map { |col| '"' + col + '"' }).join(', ')
  select_cols = (cols.map { |col| 's.' + col }).join(', ')

  str = "INSERT INTO #{archive.table_name}(#{insert_cols}) SELECT #{select_cols} FROM #{source.table_name} s "

  str += if source.has_attribute?(:institution_id)
           'JOIN institutions i ON s.institution_id = i.id JOIN versions v ON i.version_id = v.id'
         else
           'JOIN versions v ON s.version_id = v.id'
         end

  str += ' WHERE v.id = ?;'
  sql = archive.send(:sanitize_sql_for_conditions, [str, version_id])
  puts "inserting rows into #{archive}"
  ApplicationRecord.connection.execute(sql)
end

def set_source(archivable)
  return archivable[:source].joins(institution: :version) if archivable[:source].has_attribute?(:institution_id)

  archivable[:source].joins(:version)
end

def set_timeout_sql
  get_timeout_sql = "select setting from pg_settings where name = 'statement_timeout'"
  timeout_result = ActiveRecord::Base.connection.execute(get_timeout_sql).first
  timeout = timeout_result['setting']
  puts "default timeout: #{timeout}"
  puts 'setting timeout to 10 mins'
  ActiveRecord::Base.connection.execute('SET statement_timeout = 600000') # 10 minutes
  timeout_result = ActiveRecord::Base.connection.execute(get_timeout_sql).first
  puts "new timeout: #{timeout_result['setting']}"
  timeout
end
