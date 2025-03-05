# frozen_string_literal: true

module Lcpe
  module SqlContext
    class Sql
      attr_reader :gamma

      def initialize(sql = nil, &)
        if sql.present? && block_given?
          raise "can't provide both sql and block"

        elsif sql.blank? && block_given?
          context = :block
          body = Proc.new
          @gamma = [{ context:, body: }]

        elsif sql.present? && !block_given?
          context = :sql
          body = sql
          @gamma = [{ context:, body: }]

        else # if sql.blank? && !block_given?
          @gamma = []
        end
      end

      def join(ctx)
        raise "invalid object #{ctx}" unless ctx.instance_of?(self.class)

        @gamma += ctx.gamma
        self
      end

      def execute
        ActiveRecord::Base.transaction do
          gamma.each do |item|
            case item[:context]
            when :sql
              ActiveRecord::Base.connection.execute(item[:body])
            when :block
              item[:body].call
            else
              raise "invalid context: #{item[:context]}"
            end
          end
        end
      end
    end

    def pure_sql(sql = nil)
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
