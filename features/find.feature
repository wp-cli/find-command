Feature: Find WordPress installs on the filesystem

  Scenario: Two WordPress installs in subdirectories
    Given a WP install in 'subdir1'
    And a WP install in 'subdir2'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `wp find {TEST_DIR} --field=version_path | sort`
    Then STDOUT should be:
      """
      {TEST_DIR}/subdir1/wp-includes/version.php
      {TEST_DIR}/subdir2/wp-includes/version.php
      """

    When I run `wp find {TEST_DIR} --field=version_path --verbose`
    Then STDOUT should contain:
      """
      Found WordPress installation at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress installation at '{TEST_DIR}/subdir2/wp-includes/version.php'
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
      Found WordPress installation at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should not contain:
      """
      Found WordPress installation at '{TEST_DIR}/subdir2/wp-includes/version.php'
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
      Found WordPress installation at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress installation at '{TEST_DIR}/sub/subdir2/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress installation at '{TEST_DIR}/sub/sub/subdir3/wp-includes/version.php'
      """

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      3
      """

    When I run `wp find {TEST_DIR} --verbose --max_depth=2`
    Then STDOUT should contain:
      """
      Found WordPress installation at '{TEST_DIR}/subdir1/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress installation at '{TEST_DIR}/sub/subdir2/wp-includes/version.php'
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
      Found WordPress installation at '{TEST_DIR}/subdir1/wp-includes/version.php'
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

  Scenario: Invalid path specified
    Given an empty directory

    When I try `wp find foo`
    Then STDERR should be:
      """
      Error: Invalid path specified.
      """

  Scenario: List aliases for directories if they exist
    Given a WP install in 'subdir1'
    And a WP install in 'subdir2'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `echo "@test1:\n  path: {TEST_DIR}/subdir2" > wp-cli.yml`
    Then the return code should be 0

    When I run `wp find {TEST_DIR} --fields=version_path,alias`
    Then STDOUT should be a table containing rows:
      | version_path                               | alias               |
      | {TEST_DIR}/subdir1/wp-includes/version.php |                     |
      | {TEST_DIR}/subdir2/wp-includes/version.php | @test1              |

  Scenario: Ignore hidden directories by default
    Given a WP install in 'subdir1'
    And a WP install in '.svn'
    And I run `mkdir -p subdir2/.svn`
    And a WP install in 'subdir2/.svn/wp-install'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp find {TEST_DIR} --skip-ignored-paths --format=count`
    Then STDOUT should be:
      """
      3
      """

  Scenario: Use --include_ignored_paths=<paths> to include additional ignored paths
    Given a WP install in 'subdir1'
    And a WP install in 'subdir2'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      2
      """

    When I run `wp find {TEST_DIR} --include_ignored_paths='/subdir1/,/apple/' --format=count`
    Then STDOUT should be:
      """
      1
      """

  Scenario: Directories with ignored path as substring should not be ignored
    Given a WP install in 'wpblogs'
    And a WP install in 'myjs'
    And a WP install in 'logs'
    And a WP install in 'js'

    When I run `wp eval --skip-wordpress 'echo realpath( getenv( "RUN_DIR" ) );'`
    Then save STDOUT as {TEST_DIR}

    When I run `wp find {TEST_DIR} --field=version_path --verbose`
    Then STDOUT should contain:
      """
      Found WordPress installation at '{TEST_DIR}/wpblogs/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Found WordPress installation at '{TEST_DIR}/myjs/wp-includes/version.php'
      """
    And STDOUT should not contain:
      """
      Found WordPress installation at '{TEST_DIR}/logs/wp-includes/version.php'
      """
    And STDOUT should not contain:
      """
      Found WordPress installation at '{TEST_DIR}/js/wp-includes/version.php'
      """
    And STDOUT should contain:
      """
      Matched ignored path. Skipping recursion into '{TEST_DIR}/logs/'
      """
    And STDOUT should contain:
      """
      Matched ignored path. Skipping recursion into '{TEST_DIR}/js/'
      """

    When I run `wp find {TEST_DIR} --format=count`
    Then STDOUT should be:
      """
      2
      """
