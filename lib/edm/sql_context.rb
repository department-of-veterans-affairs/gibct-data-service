module Edm
  module SqlContext
    class Sql
      attr_reader :gamma

      def initialize(sql=nil)
        @gamma = sql.nil? ? [] : [sql]
      end
    
      def join(ctx)
        raise "invalid object #{ctx}" unless ctx.class == self.class

        @gamma += ctx.gamma
        self
      end
    
      def execute
        result = [
          "BEGIN;",
          gamma,
          "COMMIT;"
        ].flatten(1).join("\n")

        ActiveRecord::Base.connection.execute(result)
      end
    end
    
    def pure_sql(sql=nil)
      Sql.new(sql)
    end

    def truncate_table
      pure_sql(<<~SQL)
        TRUNCATE TABLE #{table_name};
      SQL
    end

    def drop_indices
      pure_sql(<<~SQL)
        DO $$
        DECLARE
          idx_name TEXT;
        BEGIN
          FOR idx_name IN
            SELECT indexname
            FROM pg_indexes
            WHERE tablename = '#{table_name}'
              AND indexname NOT IN (
                SELECT c2.relname
                FROM pg_constraint AS c
                JOIN pg_class AS c2 ON c.conindid = c2.oid
                WHERE c.contype = 'p' -- Primary key constraint
              )
          LOOP
            EXECUTE 'DROP INDEX IF EXISTS ' || idx_name;
          END LOOP;
        END $$;
      SQL
    end

    def reset
      pure_sql
        .join(drop_indices)
        .join(truncate_table)
        .join(rebuild)
    end
  end
end
