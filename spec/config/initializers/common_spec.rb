# frozen_string_literal: true

require 'rspec'

describe 'Common' do
  def change_deployment_env(deployment_env)
    ENV['DEPLOYMENT_ENV'] = deployment_env
    Settings.reload_from_files(
      Rails.root.join('config/settings.yml').to_s,
      Rails.root.join('config/settings', "#{Rails.env}.yml").to_s,
      Rails.root.join('config/environments', "#{Rails.env}.yml").to_s
    )
  end

  describe '#development?' do
    it 'succeeds' do
      cached_deployment_env = ENV['DEPLOYMENT_ENV']
      change_deployment_env('vagov-dev')

      expect(development?).to be_truthy

      change_deployment_env(cached_deployment_env)
    end
  end

  describe '#staging?' do
    it 'succeeds' do
      cached_deployment_env = ENV['DEPLOYMENT_ENV']
      change_deployment_env('vagov-staging')

      expect(staging?).to be_truthy

      change_deployment_env(cached_deployment_env)
    end
  end

  describe '#production?' do
    it 'succeeds' do
      cached_deployment_env = ENV['DEPLOYMENT_ENV']
      change_deployment_env('vagov-prod')

      expect(production?).to be_truthy

      change_deployment_env(cached_deployment_env)
    end
  end
end
