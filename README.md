# Gibct Data Service [![Build Status](https://dev.va.gov/jenkins/buildStatus/icon?job=department-of-veterans-affairs/gibct-data-service/master)](http://jenkins.vetsgov-internal/job/department-of-veterans-affairs/job/gibct-data-service/job/master/)

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
Institution profile data is synthesized from 21 separate CSVs maintained by various federal sources. Once the CSVs are
uploaded, a `preview` version can be compiled. The data for the `preview` version can then be viewed by using the GIBCT
in the link provided on the **GIDS** dashboard. Once the new preview version is "approved" it can then be pushed to
`production`.

## Developer Setup
Note that queries are PostgreSQL-specific.

1. Install the latest applicable version of **Postgres** on your dev box.
2. Install Ruby 2.4.5. (It is suggested to use a Ruby version manager such as [rbenv](https://github.com/rbenv/rbenv#installation) and then to [install Ruby 2.4.5](https://github.com/rbenv/rbenv#installing-ruby-versions)).
3. Install Bundler to manager dependencies: `gem install bundler -v 1.17.3` and `bundle install`
4. `npm install -g phantomjs` is necessary for running certain tests.

## Commands
- `bundle exec rake lint` - Run the full suite of linters on the codebase.
- `bundle exec guard` - Runs the guard test server that reruns your tests after files are saved. Useful for TDD!
- `bundle exec rake security` - Run the suite of security scanners on the codebase.
- `bundle exec rake ci` - Run all build steps performed in Travis CI.

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

The following are required, but related to a SAML login flow only available when the application is deployed to the VA environment. Values provided in `config/application.yml.example are suitable to get the rails server running locally, but won't provide any functionality.

5. `SAML_IDP_METADATA_FILE`: contains certificates and endpoint information provided by the SSOe team.
6. `SAML_CALLBACK_URL`: URL that will receive the identity provider's identity assertion
7. `SAML_IDP_SSO_URL`: URL where the user should be directed to authenticate to the IdP
8. `SAML_ISSUER`: shared between the GIDS and SSOe team.

The following is for use with Scorecard API.

9. `SCORECARD_API_KEY`: api_key for accessing Scorecard API see https://collegescorecard.ed.gov/data/documentation/ for how to obtain an api_key

To create these variables, you will need to create an `application.yml` file under /config. An example is posted below:

```
ADMIN_EMAIL: 'something...'
ADMIN_PW: 'something...'
SECRET_KEY_BASE: 'something ...'
LINK_HOST: 'http://localhost:3000'
GIBCT_URL: 'http://localhost:3002/gi-bill-comparison-tool'

SAML_IDP_METADATA_FILE: /path/to/config/saml/metadata.xml
SAML_CALLBACK_URL: http://localhost:3000/saml/auth/callback
SAML_IDP_SSO_URL: https://example.com/idp/sso
SAML_ISSUER: GIDS
```

You can create additional users by adding them to the `/db/seeds/01_users.rb` file:

```
User.create(email: 'xxxxxx', password: 'xxxxxx')
```

## Development Instructions
1. Run `bundle install` to set up the application.
2. Create the DS database by running `bundle exec rake db:create`.
3. Setup the DS database by running `bundle exec rake db:migrate`.
5. Load test users and sample data: `bundle exec rake db:seed`
5. Start the application: `bundle exec rails s`

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
1. Submit Pull Request
1. Discuss via Pull Request
1. Pull Request gets approved or denied by core team member

If you're from the community, it may take one to two weeks to review your pull request. Teams work in one to two week sprints, so they need time to need add it to their time line.

## Deployment

Deployment is handled the same way as `vets-api`, commits to master are tested by Jenkins and a deploy is kicked off (to change the branches, edit the Jenkinsfile) to dev and staging. Production releases are manually gated. Navigate to http://jenkins.vetsgov-internal/job/releases/job/gi-bill-data-service/ and kick off a release job with the git sha for the release and it will automatically deploy to production.

The `production` branch is kept around for references to older deployments, but is no longer in use by the deployment systems.

## Contact

If you have a question or comment about this project, file a GitHub Issue with your question in the Title, any context in the Comment, and add the `question` Label. For general questions, tag or assign to the product owner Marc Harbatkin (GitHub Handle: mphprogrammer). For design questions, tag or assign to the design lead,  Marc Harbatkin (GitHub Handle: mphprogrammer). For technical questions, tag or assign to the engineering lead, Marc Harbatkin (GitHub Handle: mphprogrammer).
