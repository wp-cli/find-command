<?php

if ( ! class_exists( 'WP_CLI' ) ) {
	return;
}

$wpcli_find_autoloader = dirname( __FILE__ ) . '/vendor/autoload.php';
if ( file_exists( $wpcli_find_autoloader ) ) {
	require_once $wpcli_find_autoloader;
}

WP_CLI::add_command( 'find', 'Find_Command' );

