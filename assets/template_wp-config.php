<?php

/**
 * This is a custom config file that is set up to load other config files
 * based on the enviroment it's running on.
 *
 * @package %SITE_PACKAGE_NAME%
 * @since 1.0.0
 */



/* =============================================================================
 * -----------------------------------------------------------------------------
 * Config Settings - START
 * -----------------------------------------------------------------------------
 * ========================================================================== */

/**
 * @since 1.0.0
 */
$_config = array(

	// ===========================================================================
	// base_url related - START
	// ===========================================================================

	'schema' => ( isset( $_SERVER['HTTPS'] ) && strtolower( $_SERVER['HTTPS'] ) != 'off' ) ? 'https' : 'http',

	// ---------------------------------------------------------------------------

	// @todo: decide which one should be used

	//'hostname' => $_SERVER['HTTP_HOST'],
	'hostname' => $_SERVER['SERVER_NAME'],

	// ---------------------------------------------------------------------------

	// if empty, will try to populate it based on __DIR__ and $_SERVER

	'base_url' => '',

	// ===========================================================================
	// base_url related - END
	// ===========================================================================



	// ===========================================================================
	// config related - START
	// ===========================================================================

	// the directory where config files are located
	// config files could reside one level above for security reasons

	//'config_dir' => __DIR__ . '/../config/',
	'config_dir' => __DIR__ . '/.config/',

	// ---------------------------------------------------------------------------

	// the config file name based on enviroment
	// develop_config.php | release_config.php | master_config.php | config.php
	// will be set in switch and used once after the switch

	'config_file_name' => '',

	// ---------------------------------------------------------------------------

	// the generic config file name such as config.php
	// used as fallback if config_file_name doesn't exist

	'config_file_name_generic' => 'config.php',

	// ===========================================================================
	// config related - END
	// ===========================================================================



	// ===========================================================================
	// wp directories - START
	// ===========================================================================

	// the relative path to where WordPress resides
	// used for defining WP_SITEURL, WP_HOME, and ABSPATH in case it isn't
	// @notes: no need to add leading or trailing slashes as they'll be trimmed

	'wp_dir' => '%wp_dir_name%', // something like 'cms'

	// ---------------------------------------------------------------------------

	// defaults to wp-content if empty

	'wp_content_foldername' => '%wp_content_foldername%', // something like 'content'

	// ===========================================================================
	// wp directories - END
	// ===========================================================================



	// ===========================================================================
	// defines related - START
	// ===========================================================================

	'defines' => array(

		// debug

		'WP_DEBUG'						=> false,
		/*
		'WP_DEBUG_DISPLAY'		=> false,
		'SCRIPT_DEBUG'				=> true,
		'CONCATENATE_SCRIPTS'	=> false,
		*/

		// -------------------------------------------------------------------------

		// misc

		'WP_POST_REVISIONS'					=> null,
		'DISABLE_WP_CRON' 					=> null,
		'AUTOMATIC_UPDATER_DISABLED'=> null,

		// -------------------------------------------------------------------------

		'WP_LOCAL_DEV' => false,

		// -------------------------------------------------------------------------

		// database defines applicable to all enviroments
		// leave unchanged unless you know what you're doing

		'DB_CHARSET' => 'utf8mb4',
		'DB_COLLATE' => '',

		// -------------------------------------------------------------------------

		// to stop asking for FTP login details when adding/updating themes/plugins

		'FS_METHOD' => 'direct',

		// -------------------------------------------------------------------------

		// database defines set by loaded enviroment config file
		// for reference only

		/*
		'DB_NAME'			=> '',
		'DB_USER'			=> '',
		'DB_PASSWORD'	=> '',
		'DB_HOST'			=> '',
		*/

		// -------------------------------------------------------------------------

		// Authentication Unique Keys and Salts set by loaded enviroment config file
		// for reference only

		/*
		'AUTH_KEY'				=> '',
		'SECURE_AUTH_KEY'	=> '',
		'LOGGED_IN_KEY'		=> '',
		'NONCE_KEY'				=> '',
		'AUTH_SALT'				=> '',
		'SECURE_AUTH_SALT'=> '',
		'LOGGED_IN_SALT' 	=> '',
		'NONCE_SALT' 			=> '',
		*/

		// -------------------------------------------------------------------------

		// Defining these values eliminates the need to edit them in the wp_options database table

		// @notes:
		//	if not set, it can be auto configured based on 'wp_dir' and $_SERVER

		/*
		'WP_SITEURL'	=> '',
		'WP_HOME'			=> 'WP_SITEURL',
		*/

		// -------------------------------------------------------------------------

		// if not set, they'll be autopulated

		/*
		'WP_CONTENT_FOLDERNAME'	=> null,
		'WP_CONTENT_DIR'				=> null,
		'WP_CONTENT_URL'				=> null,
		*/

		// -------------------------------------------------------------------------

		// Prevent non-developers from installing/updating plugins or themes

		/*
		// disable theme and plugin installers and editors
		'DISALLOW_FILE_MODS'	=> true,

		// only disable the theme/plugin editor
		'DISALLOW_FILE_EDIT'	=> true,
		*/

	),

	// ===========================================================================
	// defines related - END
	// ===========================================================================



	// ===========================================================================
	// db related - START
	// ===========================================================================

	'table_prefix' => 'wp_',

	// ===========================================================================
	// db related - END
	// ===========================================================================

);

/* =============================================================================
 * -----------------------------------------------------------------------------
 * Config Settings - END
 * -----------------------------------------------------------------------------
 * ========================================================================== */


/* That's all, stop editing! */


/* =============================================================================
 * -----------------------------------------------------------------------------
 * Base URL - START
 * -----------------------------------------------------------------------------
 * ========================================================================== */

/**
 * auto-populate base_url if not set
 *
 * @since 1.0.0
 */
if ( empty( $_config['base_url'] ) )
{
	$_config['base_url'] = $_config['schema'] . '://' . $_config['hostname'];

	// ---------------------------------------------------------------------------

	if ( ! empty( $_SERVER['CONTEXT_PREFIX'] ) )
	{
		$_config['base_url'] .= $_SERVER['CONTEXT_PREFIX'];
	}

	// ---------------------------------------------------------------------------

	if ( ! empty( $_SERVER['CONTEXT_DOCUMENT_ROOT'] ) )
	{
		$_config['base_url'] .= str_replace(
			$_SERVER['CONTEXT_DOCUMENT_ROOT'],
			'',
			__DIR__
		);
	}

	// ---------------------------------------------------------------------------

	// @todo: decide on whether to use a slash or not

	//$_config['base_url'] = rtrim( $_config['base_url'], '/' ) . '/';
}

/* =============================================================================
 * -----------------------------------------------------------------------------
 * Base URL - END
 * -----------------------------------------------------------------------------
 * ========================================================================== */


/* =============================================================================
 * -----------------------------------------------------------------------------
 * Config Settings Based on Enviroment - START
 * -----------------------------------------------------------------------------
 * ========================================================================== */

/**
 * @since 1.0.0
 */
switch ( $_SERVER['SERVER_NAME'] )
{
	// Develop Branch used in Local Development Server

	case 'localhost':
	case ( preg_match('/.localhost$/'	, $_SERVER['SERVER_NAME']) ? true : false ):
	case ( preg_match('/.local$/'			, $_SERVER['SERVER_NAME']) ? true : false ):
	case ( preg_match('/.dev$/'				, $_SERVER['SERVER_NAME']) ? true : false ):
	case ( preg_match('/.vbox$/'			, $_SERVER['SERVER_NAME']) ? true : false ):

		// set php execution time to unlimited

		set_time_limit( 0 );

		// -------------------------------------------------------------------------

		if ( empty( $_config['config_file_name'] ) )
		{
			$_config['config_file_name'] = 'develop_config.php';
		}

		// -------------------------------------------------------------------------

		$_config['defines']['WP_DEBUG']										= true;
		$_config['defines']['WP_LOCAL_DEV']								= true;
		$_config['defines']['WP_POST_REVISIONS']					= false;
		$_config['defines']['DISABLE_WP_CRON']						= true;
		$_config['defines']['AUTOMATIC_UPDATER_DISABLED']	= true;

		break;

	// ---------------------------------------------------------------------------

	// Release Branch used in Staging Server

	case ( preg_match('/release.*/'	, $_SERVER['SERVER_NAME']) ? true : false ):
	case ( preg_match('/stage.*/'		, $_SERVER['SERVER_NAME']) ? true : false ):
	case ( preg_match('/staging.*/'	, $_SERVER['SERVER_NAME']) ? true : false ):

		if ( empty( $_config['config_file_name'] ) )
		{
			$_config['config_file_name'] = 'release_config.php';
		}

		// -------------------------------------------------------------------------

		$_config['defines']['WP_DEBUG']						= true;
		$_config['defines']['WP_LOCAL_DEV']				= false;
		$_config['defines']['WP_POST_REVISIONS']	= false;

		break;

	// ---------------------------------------------------------------------------

	// Master Branch used in Production Server

	default:

		if ( empty( $_config['config_file_name'] ) )
		{
			$_config['config_file_name'] = 'master_config.php';
		}

		// -------------------------------------------------------------------------

		$_config['defines']['WP_DEBUG']						= false;
		$_config['defines']['WP_LOCAL_DEV']				= false;
		$_config['defines']['WP_POST_REVISIONS']	= null;

		break;
}

/* =============================================================================
 * -----------------------------------------------------------------------------
 * Config Settings Based on Enviroment - END
 * -----------------------------------------------------------------------------
 * ========================================================================== */



/* =============================================================================
 * -----------------------------------------------------------------------------
 * Apply Config Settings - START
 * -----------------------------------------------------------------------------
 * ========================================================================== */

/**
 * load config file
 *
 * @since 1.0.0
 */
$_config['config_file'] = $_config['config_dir'] . $_config['config_file_name'];

if ( ! file_exists( $_config['config_file'] ) )
{
	// fallback to the generic config file if it's set and it exists

	if ( ! empty( $_config['config_file_name_generic'] ) )
	{
		$_config['config_file'] = $_config['config_dir'] . $_config['config_file_name_generic'];

		if ( ! file_exists( $_config['config_file'] ) )
		{
			exit("Unable to locate {$_config['config_file']}");
		}
	}
	else
	{
		exit("Unable to locate {$_config['config_file']}");
	}
}

// we reached here, that means the file exists and we can load it

require_once $_config['config_file'];

// -----------------------------------------------------------------------------

/**
 * Make sure wp_dir is trimmed of leading and trailing slashes
 *
 * @since 1.0.0
 */
if ( ! empty( $_config['wp_dir'] ) )
{
	$_config['wp_dir'] = trim( $_config['wp_dir'], '/' );
}

// -----------------------------------------------------------------------------

/**
 * WP_SITEURL
 *
 * @since 1.0.0
 */
if ( empty( $_config['defines']['WP_SITEURL'] ) )
{
	// default to base url

	$_config['defines']['WP_SITEURL'] = $_config['base_url'];

	// ---------------------------------------------------------------------------

	if ( ! empty( $_config['wp_dir'] ) )
	{
		$_config['defines']['WP_SITEURL'] .= '/' . $_config['wp_dir'];
	}
}

// -----------------------------------------------------------------------------

/**
 * WP_HOME
 *
 * @since 1.0.0
 */
if ( empty( $_config['defines']['WP_HOME'] ) )
{
	if ( ! empty( $_config['wp_dir'] ) )
	{
		// wordpress is in it's own directory
		// set it to base url

		$_config['defines']['WP_HOME'] = $_config['base_url'];
	}
	elseif ( ! empty( $_config['defines']['WP_SITEURL'] ) )
	{
		// set to wordpress url

		$_config['defines']['WP_HOME'] = $_config['defines']['WP_SITEURL'];
	}
}

// -----------------------------------------------------------------------------

/**
 * wp-content foldername
 *
 * @since 1.0.0
 */
if ( empty( $_config['wp_content_foldername'] ) )
{
	// fallback to default wp-content dir name

	$_config['wp_content_foldername'] = 'wp-content';
}
elseif ( 'wp-content' !== $_config['wp_content_foldername'] )
{
	// set custom wp-content dir name to be defined

	if ( empty( $_config['defines']['WP_CONTENT_FOLDERNAME'] ) )
	{
		$_config['defines']['WP_CONTENT_FOLDERNAME'] = $_config['wp_content_foldername'];
	}

	// ---------------------------------------------------------------------------

	// set content dir path and url

	if ( empty( $_config['defines']['WP_CONTENT_DIR'] ) )
	{
		$_config['defines']['WP_CONTENT_DIR'] = __DIR__ . '/' . $_config['wp_content_foldername'];
	}

	if ( empty( $_config['defines']['WP_CONTENT_URL'] ) )
	{
		$_config['defines']['WP_CONTENT_URL'] = $_config['base_url'] . '/' . $_config['wp_content_foldername'];
	}
}

// -----------------------------------------------------------------------------

/**
 * defines
 *
 * @since 1.0.0
 */
if ( ! empty( $_config['defines'] ) )
{
	foreach ( $_config['defines'] as $_k => $_v )
	{
		if ( defined( $_k ) || is_null( $_v ) )
		{
			continue;
		}

		// -------------------------------------------------------------------------

		define( $_k, $_v );
	}
}

// cleanup

unset( $_k, $_v );

// -----------------------------------------------------------------------------

/**
 * WordPress Database Table prefix.
 *
 * @since 1.0.0
 */
$table_prefix  = $_config['table_prefix'];

/* =============================================================================
 * -----------------------------------------------------------------------------
 * Apply Config Settings - END
 * -----------------------------------------------------------------------------
 * ========================================================================== */



/* =============================================================================
 * -----------------------------------------------------------------------------
 * Cache Settings - START
 * -----------------------------------------------------------------------------
 * ========================================================================== */

// ref:
/*
define( 'WP_CACHE', true );
define( 'WPCACHEHOME', "{$_config['defines']['WP_CONTENT_DIR']}/plugins/wp-super-cache/" );
*/

/**
 * @since 1.0.0
define( 'WP_CACHE', false );
define( 'WPCACHEHOME', "{$_config['defines']['WP_CONTENT_DIR']}/plugins/wp-super-cache/" );
 */

/* =============================================================================
 * -----------------------------------------------------------------------------
 * Cache Settings - END
 * -----------------------------------------------------------------------------
 * ========================================================================== */


/* =============================================================================
 * -----------------------------------------------------------------------------
 * Load WordPress Settings - START
 * -----------------------------------------------------------------------------
 * ========================================================================== */

/**
 * Absolute path to the WordPress directory.
 * not really needed as it would be already defined in wp-load.php
 * which is loaded by wp-blog-header.php which in turn is loaded by index.php
 *
 * @since 1.0.0
 */
if ( ! defined('ABSPATH') )
{
	define('ABSPATH', __DIR__ . '/' . $_config['wp_dir'] . '/');
}

// -----------------------------------------------------------------------------

/**
 * cleanup the config variable
 *
 * @since 1.0.0
 */
unset( $_config );

// -----------------------------------------------------------------------------

/**
 * Sets up WordPress vars and included files.
 *
 * @since 1.0.0
 */
require_once ABSPATH . 'wp-settings.php';

/* =============================================================================
 * -----------------------------------------------------------------------------
 * Load WordPress Settings - END
 * -----------------------------------------------------------------------------
 * ========================================================================== */
