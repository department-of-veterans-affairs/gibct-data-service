require 'active_record/connection_adapters/postgresql_adapter'

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  private
  alias_method :default_configure_connection, :configure_connection

  # Monkey patch configure_connection because set_limit() must be called on a per-connection basis.
  def configure_connection
    similarity_threshold = Settings.pg_trgm&.similarity_threshold || 0.3
    default_configure_connection
    begin
      execute("SELECT set_limit(#{similarity_threshold});")
    rescue ActiveRecord::StatementInvalid
      Rails.logger.warn("pg_trgm extension not enabled yet")
    end
  end
end