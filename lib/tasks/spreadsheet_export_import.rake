# frozen_string_literal: true

####################################################
# This rake task enables you to refresh the local
# and staging environments with the latest changes
# to the spreadsheets that drive the versioning.
# It's intended to be run from an Ubuntu VM or a
# bare metal Ubuntu machine.
####################################################
# Edit your .bashrc file and add the following lines
# export LOCAL_USER="your local gids userid"
# export LOCAL_PASS="your local gids password"
# export STAGE_USER="your staging gids userid"
# export STAGE_PASS="your staging gids password"
# export PROD_USER="your prod gids userid"
# export PROD_PASS="your prod gids password"
# don't forget to source your.bashrc file when done!
#
# 4 tasks:
# 1) export from production
# 2) import to localhost
# 3) import to staging
# 4) default which runs 1 & 3
#
# To run one of the rake tasks from the command line:
# rake utils:default
# rake utils:export_csv_files_from_production
# rake utils:import_csv_files_to_localhost
# rake utils:import_csv_files_to_staging
####################################################

namespace :utils do
  desc 'Export from production and import to staging'
  task default: %i[utils:export_csv_files_from_production utils:import_csv_files_to_staging]

  desc 'Export spreadsheets used to generate versions from production'
  task export_csv_files_from_production: :environment do
    dei = DashboardExporterImporter.new(ENV['PROD_USER'], ENV['PROD_PASS'], 'p')
    dei.download_all_table_data
    dei.finalize
  end

  desc 'Import spreadsheets used to generate versions to staging'
  task import_csv_files_to_staging: :environment do
    dei = DashboardExporterImporter.new(ENV['STAGE_USER'], ENV['STAGE_PASS'], 'staging')
    dei.upload_all_table_data
    dei.finalize
    sleep(10)
    dwi = DashboardWeamImporter.new(ENV['STAGE_USER'], ENV['STAGE_PASS'], 'staging')
    dwi.upload_weam_csv_file
    dwi.finalize
  end

  desc 'Import Weam spreadsheet used to generate versions to staging'
  task import_weam_to_staging: :environment do
    dwi = DashboardWeamImporter.new(ENV['STAGE_USER'], ENV['STAGE_PASS'], 'staging')
    dwi.upload_weam_csv_file
    dwi.finalize
  end

  # Note that the vets-api and gibct need to be running locally for this to work
  desc 'Import spreadsheets used to generate versions to local development'
  task import_csv_files_to_localhost: :environment do
    dei = DashboardExporterImporter.new(ENV['LOCAL_USER'], ENV['LOCAL_PASS'], 'local')
    dei.upload_all_table_data
    dei.finalize
    sleep(10)
    dwi = DashboardWeamImporter.new(ENV['LOCAL_USER'], ENV['LOCAL_PASS'], 'local')
    dwi.upload_weam_csv_file
    dwi.finalize
  end

  desc 'Import Weam spreadsheet used to generate versions to local development'
  task import_weam_to_localhost: :environment do
    dwi = DashboardWeamImporter.new(ENV['LOCAL_USER'], ENV['LOCAL_PASS'], 'local')
    dwi.upload_weam_csv_file
    dwi.finalize
  end
end