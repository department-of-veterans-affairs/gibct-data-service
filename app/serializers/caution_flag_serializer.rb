# frozen_string_literal: true

class CautionFlagSerializer < ActiveModel::Serializer
  attributes :title, :description, :link_text, :link_url, :flag_date
end
