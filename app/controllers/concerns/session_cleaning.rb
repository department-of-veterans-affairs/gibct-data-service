# frozen_string_literal: true
module SessionCleaning
  extend ActiveSupport::Concern

  def delete_inactive_sessions!
    ActiveRecord::SessionStore::Session.delete_all ['created_at < ?', 1.week.ago]
  end
end
