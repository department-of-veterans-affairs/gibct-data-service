# frozen_string_literal: true

require 'rspec'

describe 'Docker' do
  describe 'correct bundle version' do
    let(:locked_bundle_version) do
      Bundler::Definition.build('Gemfile', nil, {}).locked_bundler_version
    end

    it 'in Dockerfile' do
      search_string = 'ENV BUNDLER_VERSION='
      docker_bundler_lines = File.foreach(Rails.root.join('Dockerfile')).grep /^#{search_string}/

      raise "#{search_string} not found in Dockerfile" unless docker_bundler_lines.any?

      docker_bundler_version = docker_bundler_lines[0].scan(/\d+.\d*.\d*/)[0]
      expect(docker_bundler_version).to eq(locked_bundle_version)
    end

    it 'installed' do
      installed_bundle_version = Gem.loaded_specs["bundler"].version.version
      expect(installed_bundle_version).to eq(locked_bundle_version)
    end
  end
end
