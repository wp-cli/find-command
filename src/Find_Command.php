<?php

use WP_CLI\Utils;

class Find_Command {

	/**
	 * Paths we can probably ignore recursion into.
	 *
	 * @var array
	 */
	private $ignored_paths = array(
		// System directories
		'/__MACOSX/',
		// Webserver directories
		'/cache/',
		'/caches/',
		'/logs/',
		'/debuglogs/',
		'/Maildir/',
		'/tmp/',
		// Generic application directories
		'/data/',
		'/uploads/',
		'/themes/',
		'/plugins/',
		'/modules/',
		'/assets/',
		'/js/',
		'/pdf/',
		'/releases/',
		'/filestore/',
		// Backup directories
		'/backup/',
		'/backups/',
		'/mysql_backups/',
		'/updater_backup/',
		// Other applications
		'/owncloud/',
		// Dependency management
		'/node_modules/',
		'/bower_components/',
		'/vendor/',
		'/svn/',
		// Already in a WordPress install
		'/wp-admin/',
		'/wp-content/',
	);

	/**
	 * Beginning of the recursion path.
	 *
	 * @var string
	 */
	private $base_path;

	/**
	 * Whether or not to skip ignored paths.
	 *
	 * @var bool
	 */
	private $skip_ignored_paths = false;

	/**
	 * Maximum folder depth to recurse into.
	 *
	 * @var integer|false
	 */
	private $max_depth = false;

	/**
	 * Current folder recursion depth.
	 *
	 * @var integer
	 */
	private $current_depth = 0;

	/**
	 * Whether or not to be verbose with informational output.
	 *
	 * @var bool
	 */
	private $verbose = false;

	/**
	 * Start time for the script.
	 *
	 * @var integer
	 */
	private $start_time = false;

	/**
	 * Resolved alias paths
	 *
	 * @var array
	 */
	private $resolved_aliases = array();

	/**
	 * Found WordPress installs.
	 *
	 * @var array
	 */
	private $found_wp = array();

	/**
	 * Find WordPress installs on the filesystem.
	 *
	 * Recursively iterates subdirectories of provided `<path>` to find and
	 * report WordPress installs. A WordPress install is a wp-includes directory
	 * with a version.php file.
	 *
	 * Avoids recursing some known paths (e.g. /node_modules/, hidden sys dirs)
	 * to significantly improve performance.
	 *
	 * Indicates depth at which the WordPress install was found, and its alias,
	 * if it has one.
	 *
	 * ```
	 * $ wp find ./
	 * +--------------------------------------+---------------------+-------+--------+
	 * | version_path                         | version             | depth | alias  |
	 * +--------------------------------------+---------------------+-------+--------+
	 * | /Users/wpcli/wp-includes/version.php | 4.8-alpha-39357-src | 2     | @wpcli |
	 * +--------------------------------------+---------------------+-------+--------+
	 * ```
	 *
	 * ## OPTIONS
	 *
	 * <path>
	 * : Path to search the subdirectories of.
	 *
	 * [--skip-ignored-paths]
	 * : Skip the paths that are ignored by default.
	 *
	 * [--max_depth=<max-depth>]
	 * : Only recurse to a specified depth, inclusive.
	 *
	 * [--fields=<fields>]
	 * : Limit the output to specific row fields.
	 *
	 * [--field=<field>]
	 * : Output a specific field for each row.
	 *
	 * [--format=<format>]
	 * : Render output in a specific format.
	 * ---
	 * default: table
	 * options:
	 *   - table
	 *   - json
	 *   - csv
	 *   - yaml
	 *   - count
	 * ---
	 *
	 * [--verbose]
	 * : Log useful information to STDOUT.
	 *
	 * @when before_wp_load
	 */
	public function __invoke( $args, $assoc_args ) {
		list( $path ) = $args;
		$this->base_path = realpath( $path );
		if ( ! $this->base_path ) {
			WP_CLI::error( 'Invalid path specified.' );
		}
		$this->skip_ignored_paths = Utils\get_flag_value( $assoc_args, 'skip-ignored-paths' );
		$this->max_depth = Utils\get_flag_value( $assoc_args, 'max_depth', false );
		$this->verbose = Utils\get_flag_value( $assoc_args, 'verbose' );

		$aliases = WP_CLI::get_runner()->aliases;
		foreach( $aliases as $alias => $target ) {
			if ( empty( $target['path'] ) ) {
				continue;
			}
			$this->resolved_aliases[ rtrim( $target['path'], '/' ) ] = $alias;
		}

		$this->start_time = microtime( true );
		$this->log( "Searching for WordPress installs in '{$path}'" );
		$this->recurse_directory( $this->base_path );
		$this->log( "Finished search for WordPress installs in '{$path}'" );
		$formatter = new \WP_CLI\Formatter( $assoc_args, array( 'version_path', 'version', 'depth', 'alias' ) );
		$formatter->display_items( $this->found_wp );
	}

	private function recurse_directory( $path ) {

		// Assume this symlink will be traversed from its true direction
		if ( is_link( $path ) ) {
			return;
		}

		// Provide consistent trailing slashes to all paths
		$path = rtrim( $path, '/' ) . '/';

		// Don't recurse directories that probably don't have a WordPress install.
		if ( ! $this->skip_ignored_paths ) {
			// Assume base path doesn't need comparison
			$compared_path = preg_replace( '#^' . preg_quote( $this->base_path ) . '#', '', $path );
			// Ignore all hidden system directories
			if ( '/.' === substr( $compared_path, 0, 2 ) ) {
				$this->log( "Matched ignored path. Skipping recursion into '{$path}'" );
				return;
			}
			foreach( $this->ignored_paths as $ignored_path ) {
				if ( false !== stripos( $compared_path, $ignored_path ) ) {
					$this->log( "Matched ignored path. Skipping recursion into '{$path}'" );
					return;
				}
			}
		}

		// This looks like a wp-includes directory, so check if it has a
		// version.php file.
		if ( '/wp-includes/' === substr( $path, -13 )
			&& file_exists( $path . 'version.php' ) ) {
			$version_path = $path . 'version.php';
			$wp_path = substr( $path, 0, -13 );
			$alias = isset( $this->resolved_aliases[ $wp_path ] ) ? $this->resolved_aliases[ $wp_path ] : '';
			$this->found_wp[ $version_path ] = array(
				'version_path' => $version_path,
				'version'      => self::get_wp_version( $version_path ),
				'depth'        => $this->current_depth - 1,
				'alias'        => $alias,
			);
			$this->log( "Found WordPress install at '{$version_path}'" );
			return;
		}

		// Ensure we haven't exceeded our max recursion depth
		if ( false !== $this->max_depth && $this->current_depth > $this->max_depth ) {
			$this->log( "Exceeded max depth. Skipping recursion into '{$path}'" );
			return;
		}

		// Check all files and directories of this path to recurse
		// into subdirectories.
		try {
			$iterator = new RecursiveDirectoryIterator( $path, FilesystemIterator::SKIP_DOTS );
		} catch( Exception $e ) {
			$this->log( "Exception thrown '{$e->getMessage()}'. Skipping recursion into '{$path}'" );
			return;
		}
		$this->log( "Recursing into '{$path}'" );
		foreach( $iterator as $file_info ) {
			if ( $file_info->isDir() ) {
				$this->current_depth++;
				$this->recurse_directory( $file_info->getPathname() );
				$this->current_depth--;
			}
		}
	}

	/**
	 * Get the WordPress version for the install, without executing the file.
	 */
	private static function get_wp_version( $path ) {
		$contents = file_get_contents( $path );
		preg_match( '#\$wp_version\s?=\s?[\'"]([^\'"]+)[\'"]#' , $contents, $matches );
		return ! empty( $matches[1] ) ? $matches[1] : '';
	}

	/**
	 * Log informational message to STDOUT depending on verbosity.
	 */
	private function log( $message ) {
		if ( $this->verbose ) {
			$elapsed_time = microtime( true ) - $this->start_time;
			WP_CLI::log( sprintf( '[%s] %s', self::format_log_timestamp( $elapsed_time ), $message ) );
		}
	}

	/**
	 * Format a log timestamp into something human-readable.
	 *
	 * @param integer $s Log time in seconds
	 * @return string
	 */
	private static function format_log_timestamp( $s ) {
		$h = floor( $s / 3600 );
		$s -= $h * 3600;
		$m = floor( $s / 60 );
		$s -= $m * 60;
		return $h . ':' . sprintf( '%02d', $m ) . ':' . sprintf( '%02d', $s );
	}

}