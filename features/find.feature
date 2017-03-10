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
      Found WordPress install at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress install at '{TEST_DIR}/subdir2/wp-includes/version.php'
      """

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      2
      """

  Scenario: WordPress install isn't found by default when in an ignored directory
    Given a WP install in 'subdir1'
    And a WP install in 'cache'
    And a WP install in 'tmp'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `wp find {TEST_DIR} --field=version_path --verbose`
    Then STDOUT should contain:
      """
      Found WordPress install at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should not contain:
      """
      Found WordPress install at '{TEST_DIR}/subdir2/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Matched ignored path. Skipping recursion into '{TEST_DIR}/cache/'
      """
    And STDOUT should contain:
      """
      Matched ignored path. Skipping recursion into '{TEST_DIR}/tmp/'
      """

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp find {TEST_DIR} --format=count --skip-ignored-paths`
    Then STDOUT should be:
      """
      3
      """

  Scenario: Use --max_depth=<depth> to specify max recursion depth
    Given a WP install in 'subdir1'
    And I run `mkdir -p sub/sub`
    And a WP install in 'sub/subdir2'
    And a WP install in 'sub/sub/subdir3'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `wp find {TEST_DIR} --verbose`
    Then STDOUT should contain:
      """
      Found WordPress install at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress install at '{TEST_DIR}/sub/subdir2/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress install at '{TEST_DIR}/sub/sub/subdir3/wp-includes/version.php'
      """

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      3
      """

    When I run `wp find {TEST_DIR} --verbose --max_depth=2`
    Then STDOUT should contain:
      """
      Found WordPress install at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress install at '{TEST_DIR}/sub/subdir2/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Exceeded max depth. Skipping recursion into '{TEST_DIR}/sub/sub/subdir3/'
      """

    When I run `wp find {TEST_DIR} --format=count --max_depth=2`
    Then STDOUT should be:
      """
      2
      """

    When I run `wp find {TEST_DIR} --verbose --max_depth=1`
    Then STDOUT should contain:
      """
      Found WordPress install at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Exceeded max depth. Skipping recursion into '{TEST_DIR}/sub/subdir2/'
      """
    And STDOUT should contain:
      """
      Exceeded max depth. Skipping recursion into '{TEST_DIR}/sub/sub/'
      """

    When I run `wp find {TEST_DIR} --format=count --max_depth=1`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp find {TEST_DIR} --verbose --max_depth=0`
    Then STDOUT should contain:
      """
      Exceeded max depth. Skipping recursion into '{TEST_DIR}/subdir1/'
      """
    And STDOUT should contain:
      """
      Exceeded max depth. Skipping recursion into '{TEST_DIR}/sub/'
      """

    When I run `wp find {TEST_DIR} --format=count --max_depth=0`
    Then STDOUT should be:
      """
      0
      """
