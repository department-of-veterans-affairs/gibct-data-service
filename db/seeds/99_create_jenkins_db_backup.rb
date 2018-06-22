# After seeding the database, we create a dump of the database.
# This dump will then be used by Jenkins for building the test state for the database.
Rake::Task['db:dump'].invoke('jenkins_db_backup')
