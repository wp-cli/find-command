wp-cli/find-command
===================

Find WordPress installs on the filesystem.

[![Build Status](https://travis-ci.org/wp-cli/find-command.svg?branch=master)](https://travis-ci.org/wp-cli/find-command)

Quick links: [Using](#using) | [Installing](#installing) | [Contributing](#contributing)

## Using

~~~
wp find <path> [--skip-ignored-paths] [--field=<field>] [--format=<format>] [--verbose]
~~~

Recursively iterates subdirectories of provided `<path>` to find and
report WordPress installs. A WordPress install is a wp-includes directory
with a version.php file.

Avoids recursing some known paths (e.g. node_modules) to significantly
improve performance.

```
$ wp find ./
+---------------------------------------------------------------------+---------------------+
| version_path                                                        | version             |
+---------------------------------------------------------------------+---------------------+
| /Users/wpcli/projects/wordpress-develop/src/wp-includes/version.php | 4.8-alpha-39357-src |
+---------------------------------------------------------------------+---------------------+
```

**OPTIONS**

	<path>
		Path to search the subdirectories of.

	[--skip-ignored-paths]
		Skip the paths that are ignored by default.

	[--field=<field>]
		Output a specific field.

	[--format=<format>]
		Render output in a specific format.
		---
		default: table
		options:
		  - table
		  - json
		  - csv
		  - yaml
		---

	[--verbose]
		Log useful information to STDOUT.

## Installing

Installing this package requires WP-CLI v0.23.0 or greater. Update to the latest stable release with `wp cli update`.

Once you've done so, you can install this package with `wp package install wp-cli/find-command`.

## Contributing

We appreciate you taking the initiative to contribute to this project.

Contributing isn’t limited to just code. We encourage you to contribute in the way that best fits your abilities, by writing tutorials, giving a demo at your local meetup, helping other users with their support questions, or revising our documentation.

### Reporting a bug

Think you’ve found a bug? We’d love for you to help us get it fixed.

Before you create a new issue, you should [search existing issues](https://github.com/wp-cli/find-command/issues?q=label%3Abug%20) to see if there’s an existing resolution to it, or if it’s already been fixed in a newer version.

Once you’ve done a bit of searching and discovered there isn’t an open or fixed issue for your bug, please [create a new issue](https://github.com/wp-cli/find-command/issues/new) with the following:

1. What you were doing (e.g. "When I run `wp post list`").
2. What you saw (e.g. "I see a fatal about a class being undefined.").
3. What you expected to see (e.g. "I expected to see the list of posts.")

Include as much detail as you can, and clear steps to reproduce if possible.

### Creating a pull request

Want to contribute a new feature? Please first [open a new issue](https://github.com/wp-cli/find-command/issues/new) to discuss whether the feature is a good fit for the project.

Once you've decided to commit the time to seeing your pull request through, please follow our guidelines for creating a pull request to make sure it's a pleasant experience:

1. Create a feature branch for each contribution.
2. Submit your pull request early for feedback.
3. Include functional tests with your changes. [Read the WP-CLI documentation](https://wp-cli.org/docs/pull-requests/#functional-tests) for an introduction.
4. Follow the [WordPress Coding Standards](http://make.wordpress.org/core/handbook/coding-standards/).


*This README.md is generated dynamically from the project's codebase using `wp scaffold package-readme` ([doc](https://github.com/wp-cli/scaffold-package-command#wp-scaffold-package-readme)). To suggest changes, please submit a pull request against the corresponding part of the codebase.*
