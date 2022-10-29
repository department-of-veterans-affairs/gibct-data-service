class GeneratePreviewJob < ApplicationJob
  queue_as :default

  def perform(current_user)
    InstitutionBuilder.run(current_user)
  end
end
