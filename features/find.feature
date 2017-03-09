Feature: Find WordPress installs on the filesystem

  Scenario: Two WordPress installs in subdirectories
    Given a WP install in 'subdir1'
    And a WP install in 'subdir2'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `wp find {TEST_DIR} --field=version_path`
    Then STDOUT should be:
      """
      {TEST_DIR}/subdir1/wp-includes/version.php
      {TEST_DIR}/subdir2/wp-includes/version.php
      """

    When I run `wp find {TEST_DIR} --field=version_path --verbose`
    Then STDOUT should contain:
      """
      Found WordPress install at {TEST_DIR}/subdir1/wp-includes/version.php
      """
    And STDOUT should contain:
      """
      Found WordPress install at {TEST_DIR}/subdir2/wp-includes/version.php
      """

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      2
      """

  Scenario: WordPress install isn't found by default when in an ignored directory
    Given a WP install in 'subdir1'
    And a WP install in 'cache'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `wp find {TEST_DIR} --field=version_path --verbose`
    Then STDOUT should contain:
      """
      Found WordPress install at {TEST_DIR}/subdir1/wp-includes/version.php
      """
    And STDOUT should not contain:
      """
      Found WordPress install at {TEST_DIR}/subdir2/wp-includes/version.php
      """
    And STDOUT should contain:
      """
      Matched ignored path. Skipping recursion into {TEST_DIR}/cache
      """

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp find {TEST_DIR} --format=count --skip-ignored-paths`
    Then STDOUT should be:
      """
      2
      """
