# frozen_string_literal: true

class CautionFlagSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :link_text, :link_url
end
