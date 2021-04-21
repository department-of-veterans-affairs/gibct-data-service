# Gibct Data Service [![Build Status](https://dev.va.gov/jenkins/buildStatus/icon?job=testing/gibct-data-service/master)](http://jenkins.vfs.va.gov/job/builds/job/gi-bill-data-service/)[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/github/department-of-veterans-affairs/gibct-data-service)[![Maintainability](https://api.codeclimate.com/v1/badges/a11398be6058464c5178/maintainability)](https://codeclimate.com/github/department-of-veterans-affairs/gibct-data-service/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/a11398be6058464c5178/test_coverage)](https://codeclimate.com/github/department-of-veterans-affairs/gibct-data-service/test_coverage) [![License: CC0-1.0](https://img.shields.io/badge/License-CC0%201.0-lightgrey.svg)](LICENSE.md)

## Introduction
The GIBCT Data Service (**GIDS**) compiles data from a variety of federal CSV-formatted sources into a set of
institution profiles that provide school metrics of value to veterans. It also offers a query-based institution search
mechanism, houses GI Bill education benefit parameters, and serves as a repository for the federal CSV source files.
Secondarily, institution information may be exported as a CSV for regulatory reporting purposes.

GIDS data is accessible via an API intended for use by the GI Bill Comparison Tool client (**GIBCT**), which is part of
the `vets-api` and `vets-website` applications.

### Data Modes and Versions
GIDS profile data is logically partitioned in two modes: **preview** mode and **production** mode. In preview mode the
data retrieved via the API has not yet been approved by the VA Education Stakeholders. In contrast, production mode is
the actual data pushed to **GIBCT** for public consumption.

### Primary User Flow
Institution profile data is synthesized from separate CSVs maintained by various federal sources. Once the CSVs are
uploaded, a `preview` version can be compiled. The data for the `preview` version can then be viewed by using the GIBCT
in the link provided on the **GIDS** dashboard. Once the new preview version is "approved" it can then be published to
`production`.

## Developer Setup
Note that queries are PostgreSQL-specific.

1. Install the latest applicable version of **Postgres** on your dev box.
2. Install Ruby 2.6.6. (It is suggested to use a Ruby version manager such as [rbenv](https://github.com/rbenv/rbenv#installation) and then to [install Ruby 2.6.6](https://github.com/rbenv/rbenv#installing-ruby-versions)).
3. Install Bundler to manager dependencies: `gem install bundler -v 2.1.4` and `bundle install`
4. `npm install -g phantomjs` is necessary for running certain tests.
5. Continue to Pre-Setup Configuration

### Issues In Setup
When running `bundle install` if this or a similar error occurs

```
An error occurred while installing libv8 (3.16.14.19), and Bundler cannot continue.
Make sure that `gem install libv8 -v '3.16.14.19' --source 'https://rubygems.org/'` succeeds
```

Run the commands to resolve the issue

```
brew install v8@3.15
bundle config --local build.libv8 --with-system-v8
bundle config --local build.therubyracer --with-v8-dir=/usr/local/opt/v8@3.15
```
## Pre-Setup Configuration

### Environment Variables
The following environment variables need to be configured for **GIDS**:

1. `GIBCT_URL`: this a link to the **GIBCT** that is used for looking at the data served by **GIDS**, and should
   point to an instance of the **GIBCT** running locally. You are not required to have an instance of **GIBCT**
	 to work on **GIDS** unless you wish to view the data in the client for which this service is intended. To learn
	 more, please refer to the [vets-api repo](https://github.com/department-of-veterans-affairs/vets-api) and
	 [vets-website repo](https://github.com/department-of-veterans-affairs/vets-website) where the **GIBCT** backend and
	 client application, respectively, are located.
2. `ADMIN_EMAIL`: This is the email you will use to sign onto **GIDS**.
3. `ADMIN_PW`: This is the password for the email (above) you will use.
4. `LINK_HOST`: This will be `http://localhost:3000`
5. `GOVDELIVERY_STAGING_SERVICE`: This is 'True' or 'False' and a string since they are set by python.
6. `GOVDELIVERY_TOKEN`: This is the token for govdelivery.com.
7. `GOVDELIVERY_URL`: This is the URL with which we send devise emails.
8. `DEPLOYMENT_ENV:`: This is the environment flag so that features can be disabled/enabled in certain environments.

The following are required, these are related to a SAML login flow only available when the application is deployed to the VA environment. Values provided in `config/application.yml.example are suitable to get the rails server running locally, but won't provide any functionality.

9. `SAML_IDP_METADATA_FILE`: contains certificates and endpoint information provided by the SSOe team.
10. `SAML_CALLBACK_URL`: URL that will receive the identity provider's identity assertion
11. `SAML_IDP_SSO_URL`: URL where the user should be directed to authenticate to the IdP
12. `SAML_ISSUER`: shared between the GIDS and SSOe team.

The following is for use with Scorecard API.

13. `SCORECARD_API_KEY`: api_key for accessing Scorecard API see https://collegescorecard.ed.gov/data/documentation/ for how to obtain an api_key

To create these variables, you will need to create an `application.yml` file under /config. An example is posted below:

```
ADMIN_EMAIL: 'something@example.gov'
ADMIN_PW: 'something...'
GIBCT_URL: 'http://localhost:3001/gi-bill-comparison-tool'
GOVDELIVERY_STAGING_SERVICE: 'True'
GOVDELIVERY_TOKEN: 'abc123'
GOVDELIVERY_URL: 'stage-tms.govdelivery.com'
LINK_HOST: 'http://localhost:3000' # https://api.va.gov
SAML_CALLBACK_URL: http://localhost:3000/saml/auth/callback
SAML_IDP_METADATA_FILE: /path/to/config/saml/metadata.xml
SAML_IDP_SSO_URL: https://example.com/idp/sso
SAML_ISSUER: GIDS
SECRET_KEY_BASE: 'something ...'
DEPLOYMENT_ENV: 'vagov-dev'
SCORECARD_API_KEY: 'api key'
```

You can create additional users by adding them to the `/db/seeds/01_users.rb` file:

```
User.create(email: 'xxxxxx', password: 'xxxxxx')
```

## Development Instructions
1. Run `bundle install` to set up the application.
2. Setup the DS database by running `bundle exec rake db:setup`.
3. Run any pending migrations by running `bundle exec rake db:migrate`.
4. Start the application: `bundle exec rails s -p 4000`
5. You should be able to access the GIDS dashboard at "http://localhost:4000"
6. Add the following in vets-api/config/settings.local.yml:
```
# Settings for GI Bill Data Service

gids:
  url: http://host.docker.internal:4000
```
7. Log in using the values for ADMIN_EMAIL and ADMIN_PW in application.yml
8. Run vets-api and vets-website and confirm that you can see the GI Bill Comparison Tool  at http://localhost:3001/gi-bill-comparison-tool.

### Cleanup local Database
```
brew services restart postgres
bundle exec rake db:drop db:create db:schema:load db:seed
```

## Commands
- `bundle exec rake lint` - Run the full suite of linters on the codebase.
- `bundle exec guard` - Runs the guard test server that reruns your tests after files are saved. Useful for TDD!
- `bundle exec rake security` - Run the suite of security scanners on the codebase.
- `bundle exec rake ci` - Runs the continuous integration scripts which includes linters, security scanners, tests, and code coverage
- `bundle exec rspec spec/path/to/spec` - Run a specific spec


## Fetching Data from the College Scorecard API
The gibct-data-service utilizes the U.S. Department of Education's College Scorecard API to retrieve some of the data for institutions that are displayed in the Comparison Tool. After obtaining and configuring your API key as described in the "Environment Variables" section of this README above, it is relatively trivial to fetch the latest data from the API.

With the GIBCT Data Service Running locally, log in to access the dashboard. From there click the green "Fetch" button on the `Scorecard` row. The Institution data will be fetched automatically from the College Scorecard API and should return a success message when complete.

Institutions have a one to many relationship with their associated degree programs. To fetch the latest data for the institution degree programs, click the green "Fetch" button on the `ScorecardDegreeProgram` row. The latest ScoreCardDegree program data will be fetched and you should receive a success message when complete.

## Version Generation
### Instituion Versioning
Much of the data in the gibct-data-service is used to build instances of institutions to display relevant data to users of the comparison tool for particular institutions. Since the data comes in as various CSV types to build these institution objects, a versioning system is necessary to ensure the correct data is being used when building the institution objects and only approved information is released to production. As mentioned in the "Data Modes and Versions" section above, there are versioned preview and production modes of the institutions that are built from the data in the uploaded CSVs. 

To generate a new preview version you must first upload any CSVs that contain changes that you wish to see in the new version of institutions being built. After you are satisfied with what has been uploaded, you must generate a new preview version by clicking "Generate New Preview Version" under the "Latest Preview Version" header on the GIBCT Dashboard. This will increment the preview version and build a new preview data set by running active record queries on the various data using [gibct-data-service/app/models/institution_builder.rb](https://github.com/department-of-veterans-affairs/gibct-data-service/blob/master/app/models/institution_builder.rb) and produce the new institution objects. You will receive a success message when this is complete.



 You can view the data contained in the new preview version by exporting the Institutions CSV by clicking the yellow "Download Export CSV" button in the "Latest Preview Version" table. A CSV download should begin producing a file with the naming convention of `institutions_version_x.csv` where x is the preview version number. If any additional CSVs need to be modified, you will need to upload them as necessary and generate another preview version.

The preview version will not be made available to the comparison tool until it is published as a production version. To publish the latest preview version as a production version, click the red "Publish to Production" button in the Latest Preview Version. Note: this will only publish the version in the environment you are working in, for example running the GIBCT service locally and publishing a preview version will not affect the staging or production environments. To check the content of the new production version you can export the Institutions CSV by clicking the yellow "Download Export CSV" button in the "Latest Production Version" table which will produce a file with the same naming convention described above.

### Additional Versioning. 
In addition to the versioned institution objects, the gibct-data-service uses versioning to keep track of other objects used in the comparison tool. These include:
 - Institution Programs: VET TEC programs and their associated information.
 - Institution Category Ratings: Data regarding experiences and various aspects of institutions to give an overall perspective on the institution and what it has to offer.
 - School Certifying Officials: Contact information for the School's Certifying Officials
 - Zipcode Rates: Location specific payment rates.
 - Caution Flags: Warning messages specific to individual institutions.
When generating a new preview or production version using the GIBCT, these objects are also versioned.
### Archived Data
All versioned data is archived using corresponding archive objects except for caution flags
 - InstitutionCategoryRatingsArchive
 - InstitutionProgramsArchive
 - VersionedSchoolCertifyingOfficialsArchive
 - ZipcodeRatesArchive
 - InstitutionsArchive
When a new preview version is created, the objects and their data in the current preview version are saved in the archive tables. The archived objects exist in case there is a reason to check what a previous version contained. At the moment there is no current way to roll back to previous versions, but this information can be accessed by querying the database(s) as necessary.

## How to Contribute

There are many ways to contribute to this project:

**Bugs**

If you spot a bug, let us know! File a GitHub Issue for this project. When filing an issue add the following:

- Title: Sentence that summarizes the bug concisely
- Comment:
    - The environment you experienced the bug (browser, browser version, kind of account any extensions enabled)
    - The exact steps you took that triggered the bug. Steps 1, 2, 3, etc.
    - The expected outcome
    - The actual outcome, including screen shot
    - (Bonus Points:) Animated GIF or video of the bug occurring
- Label: Apply the label `bug`

**Code Submissions**

This project logs all work needed and work being actively worked on via GitHub Issues. Submissions related to these are especially appreciated, but patches and additions outside of these are also great.

If you are working on something related to an existing GitHub Issue that already has an assignee, talk with them first (we don't want to waste your time). If there is no assignee, assign yourself (if you have permissions) or post a comment stating that you're working on it.

To work on your code submission, follow [GitHub Flow](https://guides.github.com/introduction/flow/):

1. Branch or Fork
1. Commit changes
1. Create draft Pull Request
1. Mark as "Ready to review" once all checks have passed
1. Discuss via Pull Request
1. Pull Request gets approved or denied by core team member

If you're from the community, it may take one to two weeks to review your pull request. Teams work in one to two week sprints, so they need time to need add it to their time line.

## Deployment

### Dev, Staging
Deployment is handled the same way as `vets-api`, commits to master are tested by Jenkins and a deploy is kicked off (to change the branches, edit the Jenkinsfile) to dev and staging.

If there are database migrations to be run 
1. Check that the relevant [dev](http://jenkins.vfs.va.gov/job/deploys/job/gi-bill-data-service-vagov-dev/) or [staging](http://jenkins.vfs.va.gov/job/deploys/job/gi-bill-data-service-vagov-staging/) deploy is finished
1. Navigate to either [dev](http://jenkins.vfs.va.gov/job/deploys/job/gi-bill-data-service-vagov-dev-post-deploy/) or [staging](http://jenkins.vfs.va.gov/job/deploys/job/gi-bill-data-service-vagov-staging-post-deploy/) post deploy actions
1. Run a "Build with Parameters" job
1. Check console output of run to ensure the migration ran correctly

### Production
Production releases are manually gated. 
1. Find the git sha you wish to use from https://github.com/department-of-veterans-affairs/gibct-data-service/commits/master
1. Navigate to http://jenkins.vfs.va.gov/job/builds/job/gi-bill-data-service/build?delay=0sec
1. Check the "Release" box
1. "Build with Parameters" with the git sha for the release and it will automatically deploy to production.

If there are database migrations to be run 
1. Check that the [prod](http://jenkins.vfs.va.gov/job/deploys/job/gi-bill-data-service-vagov-prod/) deploy is finished
1. Navigate to http://jenkins.vfs.va.gov/job/deploys/job/gi-bill-data-service-vagov-prod-post-deploy/
1. Run a "Build with Parameters" job
1. Check console output of run to ensure the migration ran correctly

### Notes
- If you do not have permission to run "Build with Parameters" jobs, contact your DSVA product owner
- The `production` branch is kept around for references to older deployments, but is no longer in use by the deployment systems.

## Contact

If you have a question or comment about this project, file a GitHub Issue with your question in the Title, any context in the Comment, and add the `question` Label. For general questions, tag or assign to the product owner Marc Harbatkin (GitHub Handle: mphprogrammer). For design questions, tag or assign to the design lead,  Marc Harbatkin (GitHub Handle: mphprogrammer). For technical questions, tag or assign to the engineering lead, Marc Harbatkin (GitHub Handle: mphprogrammer).
