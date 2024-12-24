module CanNormalizeLcpeUpload
  class Helper
    attr_reader :csv_type

    def initialize(csv_type:)
      @csv_type = csv_type
    end

    def top_most
      return @top_most if defined? @top_most

      @top_most = csv_type&.split("::").first.constantize rescue nil
    end

    def subject
      return @subject if defined? @subject

      @subject = csv_type&.constantize rescue nil
    end

    def valid_question
      return @valid_question if defined? @valid_question

      @valid_question = top_most == Lcpe && subject.respond_to?(:normalize)
    end

    def normalize!
      return unless valid?

      subject.normalize.execute
    end

    alias valid? valid_question
  end

  extend ActiveSupport::Concern

  included do
    after_save :normalize_lcpe!
  end

  private 

  def normalize_lcpe!
    return unless self.ok?

    Helper.new(csv_type:).normalize!
  end
end
