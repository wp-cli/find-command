<?php

if ( ! class_exists( 'WP_CLI' ) ) {
	return;
}

use WP_CLI\Utils;

class Find_Command {

	/**
	 * Paths we can probably ignore recursion into.
	 *
	 * @var array
	 */
	private $ignored_paths = array(
		'/.git/',
		'/.svn/',
		'/logs/',
		'/wp-admin/',
		'/wp-content/',
		'/node_modules/',
		'/bower_components/',
	);

	/**
	 * Whether or not to skip ignored paths.
	 *
	 * @var bool
	 */
	private $skip_ignored_paths = false;

	/**
	 * Whether or not to be verbose with informational output.
	 *
	 * @var bool
	 */
	private $verbose = false;

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
	 * Avoids recursing some known paths (e.g. node_modules) to significantly
	 * improve performance.
	 *
	 * ## OPTIONS
	 *
	 * <path>
	 * : Path to search the subdirectories of.
	 *
	 * [--depth=<depth>]
	 * : Limit recursion to a specific depth.
	 *
	 * [--skip-ignored-paths]
	 * : Skip the paths that are ignored by default.
	 *
	 * [--field=<field>]
	 * : Output a specific field.
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
	 * ---
	 *
	 * [--verbose]
	 * : Log useful information to STDOUT.
	 *
	 * @when before_wp_load
	 */
	public function __invoke( $args, $assoc_args ) {
		list( $path ) = $args;
		$path = realpath( $path );
		$this->skip_ignored_paths = Utils\get_flag_value( $assoc_args, 'skip-ignored-paths' );
		$this->verbose = Utils\get_flag_value( $assoc_args, 'verbose' );
		$this->log( "Searching for WordPress installs in {$path}" );
		$this->recurse_directory( $path );
		$formatter = new \WP_CLI\Formatter( $assoc_args, array( 'version_path', 'version' ) );
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
			foreach( $this->ignored_paths as $ignored_path ) {
				if ( false !== stripos( $path, $ignored_path ) ) {
					$this->log( "Matched ignored path. Skipping recursion into {$path}" );
					return;
				}
			}
		}

		// This looks like a wp-includes directory, so check if it has a
		// version.php file.
		if ( '/wp-includes/' === substr( $path, -13 )
			&& file_exists( $path . 'version.php' ) ) {
			$version_path = $path . 'version.php';
			$this->found_wp[ $version_path ] = array(
				'version_path' => $version_path,
				'version'      => self::get_wp_version( $version_path ),
			);
			$this->log( "Found WordPress install at {$version_path}" );
			return;
		}

		// Check all files and directories of this path to recurse
		// into subdirectories.
		$this->log( "Recusing into {$path}" );
		$iterator = new RecursiveDirectoryIterator( $path, FilesystemIterator::SKIP_DOTS );
		foreach( $iterator as $file_info ) {
			if ( $file_info->isDir() ) {
				$this->recurse_directory( $file_info->getPathname() );
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
			WP_CLI::log( $message );
		}
	}

}
WP_CLI::add_command( 'find', 'Find_Command' );

