# frozen_string_literal: true
class StoragesController < ApplicationController
  def index
    @storages = Storage.all
  end
end
