# Should only be executed in local dev environements to generate mock data for development purposes. 
# It expects data that is extracted from the current WEAMS Public site.
module Lcpe
  class LoadMocks
    attr_reader :plan_path

    def initialize(plan_path:)
      @plan_path = plan_path
    end

    def plan
      return @plan if defined?(@plan)

      @plan = Config.load_files(plan_path)
      @plan.tap { validate_plan! }
    end

    def chunk_size
      return @chunk_size if defined?(@chunk_size)

      @chunk_size = plan.setup.chunk_size
    end

    def validate_plan!
      plan.paths.each do |k, v| 
        raise "missing value path for #{k} in plan" if v.blank?
        plan.paths[k] = Pathname(v)
      end

      plan.paths.to_h.except(:result).each do |k, v|
        raise "invalid path: #{v} for #{k} in plan" unless v.exist?
      end
      
      raise "directory to place results not in plan" unless plan.paths.output.present?
    end

    def import_schema
      @import_schema ||= "import_#{Time.now.strftime('%Y%m%dt%H%M%Sj')}"
    end

    def create_schema
      print(format("Creating schema: %<import_schema>s: ", {import_schema:}))
      ActiveRecord::Base.connection.execute(format(plan.setup.create_schema, import_schema:))
      puts "done"
    end

    def drop_schema
      print(format("Dropping schema: %<import_schema>s: ", {import_schema:}))
      ActiveRecord::Base.connection.execute(format(plan.setup.drop_schema, import_schema:))
      puts "done"
    end

    def create_tables
      plan.tables.each do |_, table|
        name = table.name
        print(format("Creating table: %<import_schema>s.%<name>s: ", {import_schema:, name:}))
        ActiveRecord::Base.connection.execute(format(table.create_sql, {import_schema:, name:}))
        puts "done"
      end
    end

    def connection
      ActiveRecord::Base.connection.raw_connection
    end

    def upload(path:, sql:)
      io = path.open('r')
      size = path.size
      round = 0
      next_percent = 10

      connection.copy_data(sql) do
        loop do
          location = chunk_size * round
          percent = ((location.to_f / size) * 100).round

          if percent >= next_percent && percent < 100
            print "#{percent}%, "
            next_percent += 10
          end

          chunk = io.readpartial(chunk_size)
          connection.put_copy_data(chunk)
          round += 1
        rescue EOFError
          break
        end
      end
    end

    def upload_tables
      plan.tables.each do |_, table|
        name = table.name
        path = Pathname(table.path)
        sql = format(table.upload_sql, {import_schema:, name:})
        print(format(
          "Loading rows from %<path>s into: %<import_schema>s.%<name>s: ", 
          {path:, import_schema:, name:}
        ))
        upload(path:, sql:)
        puts "done"
      end
    end

    def institutions_mappings_query
      return @institutions_mappings_query if defined?(@institutions_mappings_query)

      @institutions_mappings_query =
        format(
          plan.setup.institutions_mappings_query,
          {import_schema:}
        )
    end

    def download(name:, sql:, path:)
      dest_path = plan.paths.output / import_schema / path.basename
      dest_path.parent.mkpath
      io = dest_path.open('w:ISO-8859-1')
      row = 0

      print(format(
        "Loading rows from %<import_schema>s.%<name>s into: %<dest_path>s: ",
        {import_schema:, name:, dest_path:}
      ))
      connection.copy_data(sql) do
        while (chunk = connection.get_copy_data)
          io.write(chunk.force_encoding('ISO-8859-1'))
          print "#{row}, " if (row % 10_000).zero?
          row += 1
        end
      end
      puts "done"
    end

    def download_tables
      plan.tables.each do |_, table|
        next unless table.download_sql.present?

        name = table.name
        sql = format(table.download_sql, {institutions_mappings_query:, import_schema:, name:})
        path = Pathname(table.path)
        download(name:, sql:, path:)
      end
    end

    def perform
      create_schema
      create_tables
      upload_tables
      download_tables
    ensure
      drop_schema
      puts "Finished"
    end
  end
end
