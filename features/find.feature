Feature: Find WordPress installs on the filesystem

  Scenario: Two WordPress installs in subdirectories
    Given a WP install in 'subdir1'
    And a WP install in 'subdir2'

    When I run `wp find ./ --field=version_path`
    Then STDOUT should contain:
      """
      {RUN_DIR}/subdir1/wp-includes/version.php
      """
    And STDOUT should contain:
      """
      {RUN_DIR}/subdir2/wp-includes/version.php
      """

    When I run `wp find ./ --format=count`
    Then STDOUT should be:
      """
      2
      """

  Scenario: WordPress install isn't found by default when in an ignored directory
    Given a WP install in 'subdir1'
    And a WP install in 'cache'

    When I run `wp find ./ --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp find ./ --format=count --skip-ignored-paths`
    Then STDOUT should be:
      """
      2
      """
