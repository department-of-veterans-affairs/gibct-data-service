# Gibct Data Service [![Build Status](https://dev.vets.gov/jenkins/buildStatus/icon?job=department-of-veterans-affairs/gibct-data-service/master)](http://jenkins.vetsgov-internal/job/department-of-veterans-affairs/job/gibct-data-service/job/master/)

## Introduction
The GIBCT Data Service (**GIDS**) compiles data from a variety of federal CSV-formatted sources into a set of
institution profiles that provide school metrics of value to veterans. It also offers a query-based institution search
mechanism, houses GI Bill education benefit parameters, and serves as a repository for the federal CSV source files.
Secondarily, institution information may be exported as a CSV for regulatory reporting purposes.

GIDS data is accessible via an API intended for use by the GI Bill Comparison Tool client.

### Data Modes and Versions
GIDS profile data is logically partitioned in two modes: **preview** mode and **production** mode. In preview mode the
data retrieved via the API has not yet been approved by the VA Education Stakeholders. In contrast

### Primary Administrative Flow
Institution profile data is synthesized from 21 separate CSVs maintained by various federal sources. Once the CSVs are
uploaded





## Developer Setup
Note that queries are PostgreSQL-specific.

1. Install the latest applicable version of **Postgres** on your dev box.
2. Install Ruby 2.3. (It is suggested to use a Ruby version manager such as [rbenv](https://github.com/rbenv/rbenv#installation) and then to [install Ruby 2.3](https://github.com/rbenv/rbenv#installing-ruby-versions)).
3. Install Bundler to manager dependencies: `gem install bundler` and `bundle install`
4. `npm install -g phantomjs` is necessary for running certain tests.

## Commands
- `bundle exec rake lint` - Run the full suite of linters on the codebase.
- `bundle exec guard` - Runs the guard test server that reruns your tests after files are saved. Useful for TDD!
- `bundle exec rake security` - Run the suite of security scanners on the codebase.
- `bundle exec rake ci` - Run all build steps performed in Travis CI.

## Deployment Instructions

1. Run `bundle install` to set up the application.
2. Create the DS database by running `bundle exec rake db:create`.
3. Setup the DS database by running `bundle exec rake db:migrate`.
4. Edit the seeds.rb file to create a user.
5. Load test users: `bundle exec rake db:seed`
5. Start the application: `bundle exec rails s`

### The Seeds file

The DS uses authentication, and you need to populate the application's users table with qualified logins.

	# Destroy previous users ...
	User.destroy_all

	puts 'Add new users ... '
	User.create(email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PW'])

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

## Contact

If you have a question or comment about this project, file a GitHub Issue with your question in the Title, any context in the Comment, and add the `question` Label. For general questions, tag or assign to the product owner Marc Harbatkin (GitHub Handle: mphprogrammer). For design questions, tag or assign to the design lead,  Marc Harbatkin (GitHub Handle: mphprogrammer). For technical questions, tag or assign to the engineering lead, Marc Harbatkin (GitHub Handle: mphprogrammer).
