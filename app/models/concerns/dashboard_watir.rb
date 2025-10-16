# frozen_string_literal: true

module DashboardWatir
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    LOCAL_URL ||= 'http://localhost:4000/user/sign_in'
    LOCAL_DASHBOARD ||= 'http://localhost:4000/dashboards'
    LOCAL_IMPORT_PREFIX ||= '/uploads/new/'

    PROD_URL ||= 'https://www.va.gov/gids/user/sign_in'
    EXPORT_PREFIX ||= '/gids/dashboards/export/'

    STAGE_URL ||= 'https://staging.va.gov/gids/user/sign_in'
    STAGE_DASHBOARD ||= 'https://staging.va.gov/gids/dashboards'
    STAGE_IMPORT_PREFIX ||= '/gids/uploads/new/'

    TIMEOUT ||= 600 # seconds

    attr_accessor :headless, :bsess, :download_dir, :login_url,
                  :dashboard_url, :import_prefix, :user, :pass, :eilogger,
                  :workfiles

    def common_initialize_watir(user, pass, load_env = nil)
      @user = user
      @pass = pass

      set_logger
      set_url_variables_for_job(load_env)

      @download_dir = set_download_dir
      @headless = Headless.new
      @headless.start
    end

    def finalize
      @headless.destroy
      log_and_puts('*** All done! You can close this terminal window. ***')
    end

    private

    # load_env is target enviroment for upload/download
    def set_url_variables_for_job(load_env)
      case load_env
      when 'l', 'local', 'localhost'
        @login_url = LOCAL_URL
        @dashboard_url = LOCAL_DASHBOARD
        @import_prefix = LOCAL_IMPORT_PREFIX
      when 'production', 'prod', 'p'
        @login_url = PROD_URL
      else
        @login_url = STAGE_URL
        @dashboard_url = STAGE_DASHBOARD
        @import_prefix = STAGE_IMPORT_PREFIX
      end
    end

    def set_download_dir
      return ENV['HOME'] + '/Downloads' if ENV['RAILS_ENV'].nil? || ENV['RAILS_ENV'].eql?('development')

      Rails.root.join('tmp')
    end

    # rubocop:disable Lint/RescueException
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Rails/Exit
    # rubocop:disable Metrics/AbcSize
    def login_to_dashboard
      log_and_puts('*** Logging in to the Dashboard ***')

      begin
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.read_timeout = TIMEOUT # seconds
        client.open_timeout = TIMEOUT # seconds
        @bsess = Watir::Browser.start(@login_url, http_client: client)
        @bsess.driver.manage.timeouts.page_load = 600 # seconds
        @bsess.driver.manage.timeouts.script_timeout = 600 # seconds
        @bsess.driver.manage.timeouts.implicit_wait = 90 # seconds
      rescue Exception => e
        log_and_puts("       Error trying to initiate browser session #{e.message}...")
        log_and_puts('       Trying again in 10 seconds...')
        sleep(10)
        @bsess = nil
        begin
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.read_timeout = TIMEOUT # seconds
          client.open_timeout = TIMEOUT # seconds
          @bsess = Watir::Browser.start(@login_url, http_client: client)
          @bsess.driver.manage.timeouts.page_load = 600 # seconds
          @bsess.driver.manage.timeouts.script_timeout = 600 # seconds
          @bsess.driver.manage.timeouts.implicit_wait = 90 # seconds
        rescue Exception => e
          log_and_puts("       Failed again #{e.message}...")
          exit 1
        end
      end
      @bsess.text_field(id: 'user_email').set(@user)
      @bsess.text_field(id: 'user_password').set(@pass)
      @bsess.form(id: 'new_user').submit
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Rails/Exit
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Lint/RescueException

    def log_out_and_back_in(table_name)
      log_and_puts('*** Logging out')
      @bsess.link(text: 'Log Out').click if @bsess.link(text: 'Log Out').present?
      @bsess.close # close the browser session to free up memory
      @bsess = nil 
      log_and_puts ''
      sleep(5)

      if table_name.eql?('Section1015') # last table in the array
        log_and_puts('*** Finished uploading tables ***')
      else
        login_to_dashboard
      end
    end

    def log_and_puts(msg)
      msg = "#{Time.now.getlocal} - #{msg}" if msg.size.positive?
      @eilogger.info(msg)
    end
  end
  # rubocop:enable Metrics/BlockLength
end
