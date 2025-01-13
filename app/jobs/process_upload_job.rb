# frozen_string_literal: true

class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload)
    byebug
  end
end
