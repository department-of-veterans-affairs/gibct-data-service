# frozen_string_literal: true

FactoryBot.define do
  factory :version_public_export do
    version
    file_type { 'application/x-gzip' }
    data { "\u001F\x8B\b\b\xAD\x8CHh\u0000\u0003temp.txt\u0000\xCBH\xCD\xC9\xC9\xE7\u0002\u0000 0:6\u0006\u0000\u0000\u0000" }
  end
end
