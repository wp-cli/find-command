wp-cli/find-command
===================

Find WordPress installations on the filesystem.

[![Build Status](https://travis-ci.org/wp-cli/find-command.svg?branch=master)](https://travis-ci.org/wp-cli/find-command)

Quick links: [Using](#using) | [Installing](#installing) | [Contributing](#contributing) | [Support](#support)

## Using

~~~
wp find <path> [--skip-ignored-paths] [--include_ignored_paths=<paths>] [--max_depth=<max-depth>] [--fields=<fields>] [--field=<field>] [--format=<format>] [--verbose]
~~~

Recursively iterates subdirectories of provided <path> to find and
report WordPress installations. A WordPress installation is a wp-includes
directory with a version.php file.

Avoids recursing some known paths (e.g. /node_modules/, hidden sys dirs)
to significantly improve performance.

Indicates depth at which the WordPress installations was found, and its
alias, if it has one.

```
$ wp find ./
+--------------------------------------+---------------------+-------+--------+
| version_path                         | version             | depth | alias  |
+--------------------------------------+---------------------+-------+--------+
| /Users/wpcli/wp-includes/version.php | 4.8-alpha-39357-src | 2     | @wpcli |
+--------------------------------------+---------------------+-------+--------+
```

**AVAILABLE FIELDS**

These fields will be displayed by default for each installation:

* version_path - Path to the version.php file.
* version - WordPress version.
* depth - Directory depth at which the installation was found.
* alias - WP-CLI alias, if one is registered.

These fields are optionally available:

* wp_path - Path that can be passed to `--path=<path>` global parameter.
* db_host - Host name for the database.
* db_user - User name for the database.
* db_name - Database name for the database.

**OPTIONS**

	<path>
		Path to search the subdirectories of.

	[--skip-ignored-paths]
		Skip the paths that are ignored by default.

	[--include_ignored_paths=<paths>]
		Include additional ignored paths as CSV (e.g. '/sys-backup/,/temp/').

	[--max_depth=<max-depth>]
		Only recurse to a specified depth, inclusive.

	[--fields=<fields>]
		Limit the output to specific row fields.

	[--field=<field>]
		Output a specific field for each row.

	[--format=<format>]
		Render output in a specific format.
		---
		default: table
		options:
		  - table
		  - json
		  - csv
		  - yaml
		  - count
		---

	[--verbose]
		Log useful information to STDOUT.

## Installing

Installing this package requires WP-CLI v2 or greater. Update to the latest stable release with `wp cli update`.

Once you've done so, you can install the latest stable version of this package with:

```bash
wp package install wp-cli/find-command:@stable
```

To install the latest development version of this package, use the following command instead:

```bash
wp package install wp-cli/find-command:dev-master
```

## Contributing

We appreciate you taking the initiative to contribute to this project.

Contributing isn’t limited to just code. We encourage you to contribute in the way that best fits your abilities, by writing tutorials, giving a demo at your local meetup, helping other users with their support questions, or revising our documentation.

For a more thorough introduction, [check out WP-CLI's guide to contributing](https://make.wordpress.org/cli/handbook/contributing/). This package follows those policy and guidelines.

### Reporting a bug

Think you’ve found a bug? We’d love for you to help us get it fixed.

Before you create a new issue, you should [search existing issues](https://github.com/wp-cli/find-command/issues?q=label%3Abug%20) to see if there’s an existing resolution to it, or if it’s already been fixed in a newer version.

Once you’ve done a bit of searching and discovered there isn’t an open or fixed issue for your bug, please [create a new issue](https://github.com/wp-cli/find-command/issues/new). Include as much detail as you can, and clear steps to reproduce if possible. For more guidance, [review our bug report documentation](https://make.wordpress.org/cli/handbook/bug-reports/).

### Creating a pull request

Want to contribute a new feature? Please first [open a new issue](https://github.com/wp-cli/find-command/issues/new) to discuss whether the feature is a good fit for the project.

Once you've decided to commit the time to seeing your pull request through, [please follow our guidelines for creating a pull request](https://make.wordpress.org/cli/handbook/pull-requests/) to make sure it's a pleasant experience. See "[Setting up](https://make.wordpress.org/cli/handbook/pull-requests/#setting-up)" for details specific to working on this package locally.

## Support

GitHub issues aren't for general support questions, but there are other venues you can try: https://wp-cli.org/#support


*This README.md is generated dynamically from the project's codebase using `wp scaffold package-readme` ([doc](https://github.com/wp-cli/scaffold-package-command#wp-scaffold-package-readme)). To suggest changes, please submit a pull request against the corresponding part of the codebase.*
