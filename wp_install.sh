#!/bin/bash


# ==============================================================================
# USAGE AND NOTES - START
# ==============================================================================
#
# - Info:
#		- author : Webmasterish
#		- created: 2017-08-23
#
# ------------------------------------------------------------------------------
#
# - Command:
# 		bash wp_install.sh or ./wp_install.sh
#
# ==============================================================================
# USAGE AND NOTES - END
# ==============================================================================



# ==============================================================================
# SCRIPT RELATED - START
# ==============================================================================

get_script_file()
{

	local _out

	# ----------------------------------------------------------------------------

	# find the script dir; if running by bash or directly
	# this is important so we can source the files

	if [ -n "${BASH_SOURCE}" ]; then

		_out="${BASH_SOURCE}"

	else

		_out="${0}"

	fi

	# ----------------------------------------------------------------------------

	echo "${_out}"

}
# get_script_file()



get_script_file_absolute_path()
{

	local _out="$(get_script_file)"

	# ----------------------------------------------------------------------------

	_out=$(readlink -f "${_out}")

	#pwd -P

	# ----------------------------------------------------------------------------

	echo "${_out}"

}
# get_script_file_absolute_path()



get_script_file_name()
{

	# similar to using ${0##*/}
	# but accounts for ${BASH_SOURCE}

	echo $(basename $(get_script_file))

}
# get_script_file_name()



get_script_dir_path()
{

	#echo $(dirname $(get_script_file))

	echo $(dirname $(get_script_file_absolute_path))

}
# get_script_dir_path()

# ------------------------------------------------------------------------------

# script info - read only associative array using "-Ar"

#declare -Ar SCRIPT_INFO=(
declare -A SCRIPT_INFO=(

	[name]="WP Install"
	[version]="0.1.2"
	[version_date]="2022-05-14"
	[author]="Webmasterish"
	[url]="http://webmasterish.com/"
	[file]="$(get_script_file)"
	[file_name]="$(get_script_file_name)"
	[dir]="$(get_script_dir_path)"

)

SCRIPT_INFO[dir_assets]="${SCRIPT_INFO[dir]}/assets"

# set it as read only
declare -r SCRIPT_INFO

# ==============================================================================
# SCRIPT RELATED - END
# ==============================================================================



# ==============================================================================
# CONFIG - START
# ==============================================================================

declare -A SETTINGS=(

	["pwd"]="${PWD}"

	["wp_source_url"]="http://wordpress.org/latest.tar.gz"
	["wp_salt_keys_url"]="https://api.wordpress.org/secret-key/1.1/salt/"

	["wp_dir_name"]="cms"
	["wp_content_foldername"]="content"

	# @see settings_populate() how default values are set
	["dir"]=""
	["url"]=""
	["title"]=""
	["admin_url"]=""
	["admin_username"]=""
	["admin_password"]=""
	["install_url"]=""

	# @see settings_populate_mysql() how default values are set
	["mysql_host"]=""
	["mysql_user"]=""
	["mysql_password"]=""
	["mysql_db_name"]=""
	["mysql_collate"]=""

	["testing"]=""

)

# ==============================================================================
# CONFIG - END
# ==============================================================================



# ==============================================================================
# LOGICAL CHECKS RELATED - START
# ==============================================================================

is_root()
{

	[[ "${UID}" -eq 0 ]]

}
# is_root()



is_curl_installed()
{

	command -v curl >/dev/null 2>&1

	# ----------------------------------------------------------------------------

	[[ $? -eq 0 ]]

}
# is_curl_installed() - End



is_tar_installed()
{

	command -v tar >/dev/null 2>&1

	# ----------------------------------------------------------------------------

	[[ $? -eq 0 ]]

}
# is_tar_installed() - End



is_mysql_installed()
{

	command -v mysql >/dev/null 2>&1

	# ----------------------------------------------------------------------------

	[[ $? -eq 0 ]]

}
# is_mysql_installed() - End



is_php_installed()
{

	command -v php >/dev/null 2>&1

	# ----------------------------------------------------------------------------

	[[ $? -eq 0 ]]

}
# is_php_installed() - End



is_valid_url()
{

	local _regex="^https?://.*"

	# ----------------------------------------------------------------------------

	[[ $1 =~ $_regex ]]

}
# is_valid_url() - End

# ==============================================================================
# LOGICAL CHECKS RELATED - END
# ==============================================================================



# ==============================================================================
# STRING RELATED - START
# ==============================================================================

untrailing_slash_it()
{

	local _out="${1}"

	# ----------------------------------------------------------------------------

	if [ -n "${_out}" ]; then

		# @notes:
		# this will only remove the last slash,
		# needs a better way to remove all slashes at the end

		_out="${_out%/}"

	fi

	# ----------------------------------------------------------------------------

	echo "${_out}"

}
# untrailing_slash_it()



unleading_slash_it()
{

	local _out="${1}"

	# ----------------------------------------------------------------------------

	if [ -n "${_out}" ]; then

		# @notes:
		# this will only remove the last slash,
		# needs a better way to remove all slashes at the begining

		_out="${_out#/}"

	fi

	# ----------------------------------------------------------------------------

	echo "${_out}"

}
# unleading_slash_it()



trim_slashes()
{

	# remove leading and trailing slashes

	local _out="${1}"

	# ----------------------------------------------------------------------------

	_out=$(untrailing_slash_it "${_out}")
	_out=$(unleading_slash_it "${_out}")

	# ----------------------------------------------------------------------------

	echo "${_out}"

}
# trim_slashes()



trailing_slash_it()
{

	echo $(untrailing_slash_it "${1}")"/"

}
# trailing_slash_it()



join_path()
{

	local _out=$(trailing_slash_it "${1}")$(unleading_slash_it "${2}")

	# --------------------------------------------------------------------------

	echo "${_out}"

}
# join_path()



get_humanized()
{

	local _out="${1}"

	# ----------------------------------------------------------------------------

	# replace underscores, dashes and slashes if not empty

	if [ -n "${_out}" ]; then

		_out=${_out//["_-\/"]/" "}

	fi

	# ----------------------------------------------------------------------------

	# title case - maybe make it as optional by using ${2}

	_out=(${_out})		# make it an arr
	_out=${_out[@]^}	# title case

	# ----------------------------------------------------------------------------

	# return it by echo

	echo "${_out}"

}
# get_humanized()



get_sanitized_dir_name()
{

	local _out="${1}"

	# ----------------------------------------------------------------------------

	# make it lowercase

	_out=${_out,,}

	# ----------------------------------------------------------------------------

	# replace spaces with underscore

	_out=${_out//[" "]/"_"}

	# ----------------------------------------------------------------------------

	# remove anything that's not alphanumeric or underscore or dash or dot

	_out=${_out//[^a-zA-Z0-9_\-\/\.]/}

	# ----------------------------------------------------------------------------

	# return it by echo

	echo "${_out}"

}
# get_sanitized_dir_name()



get_sanitized_mysql_db_name()
{

	local _out="${1}"

	# ----------------------------------------------------------------------------

	# make it lowercase

	_out=${_out,,}

	# ----------------------------------------------------------------------------

	# replace spaces, slashes, dots, and dashes with underscore

	_out=${_out//[" "\/\.\-]/"_"}

	# ----------------------------------------------------------------------------

	# remove anything that's not alphanumeric or underscore or dash

	_out=${_out//[^a-zA-Z0-9_\-]/}

	# ----------------------------------------------------------------------------

	# @todo max name length 64

	# ----------------------------------------------------------------------------

	# return it by echo

	echo "${_out}"

}
# get_sanitized_mysql_db_name()

# ==============================================================================
# STRING RELATED - END
# ==============================================================================



# ==============================================================================
# PRINT RELATED - START
# ==============================================================================

print_black()			{ echo -e "$(tput setaf 0)$*$(tput setaf 9)"; }
print_red()				{ echo -e "$(tput setaf 1)$*$(tput setaf 9)"; }
print_green()			{ echo -e "$(tput setaf 2)$*$(tput setaf 9)"; }
print_yellow()		{ echo -e "$(tput setaf 3)$*$(tput setaf 9)"; }
print_blue()			{ echo -e "$(tput setaf 4)$*$(tput setaf 9)"; }
print_magenta()		{ echo -e "$(tput setaf 5)$*$(tput setaf 9)"; }
print_cyan()			{ echo -e "$(tput setaf 6)$*$(tput setaf 9)"; }
print_gray()			{ echo -e "$(tput setaf 7)$*$(tput setaf 9)"; }
print_light_gray(){ echo -e "$(tput setaf 8)$*$(tput setaf 9)"; }
print_white()			{ echo -e "$(tput setaf 9)$*$(tput setaf 9)"; }

# ------------------------------------------------------------------------------

print_repeat_string()
{

	local _str="${1}"
	local _num="${2:-1}"

	# ----------------------------------------------------------------------------

	if [ -n "${_str}" ]; then

		printf "%0.s${_str}" $(seq 1 $_num)
		echo

	fi

}
# print_repeat_string()



print_script_info()
{

	local _i

	# ----------------------------------------------------------------------------

	for _i in "${!SCRIPT_INFO[@]}"; do

		printf " - %s:\t%s\n" "$_i" "${SCRIPT_INFO[$_i]}"

	done | sort -k1

}
# print_script_info()



print_settings()
{

	local _i

	# ----------------------------------------------------------------------------

	# @todo: this doesn't have good readability, i'll use manual for now

	#for _i in "${!SETTINGS[@]}"; do

		#printf " - %s:\t%s\n" "$_i" "${SETTINGS[$_i]}"

	#done | sort -k1

	# ----------------------------------------------------------------------------

	# hide/mask password if not testing

	local _mysql_password="${SETTINGS[mysql_password]}"

	if [ -z "${SETTINGS[testing]}" ]; then

		_mysql_password=$(print_repeat_string "*" ${#SETTINGS[mysql_password]})

	fi

	# ----------------------------------------------------------------------------

	local _settings=(
		"- PWD                : ${SETTINGS[pwd]}"
		"- Directory          : ${SETTINGS[dir]}"

		"- WP Source URL      : ${SETTINGS[wp_source_url]}"
		"- WP Salt Keys URL   : ${SETTINGS[wp_salt_keys_url]}"
		"- WP Dir Name        : ${SETTINGS[wp_dir_name]}"
		"- WP Content Dir Name: ${SETTINGS[wp_content_foldername]}"

		"- URL                : ${SETTINGS[url]}"
		"- Admin URL          : ${SETTINGS[admin_url]}"
		"- Install URL        : ${SETTINGS[install_url]}"
		"- Domain             : ${SETTINGS[domain]}"
		"- Admin Username     : ${SETTINGS[admin_username]}"
		"- Admin Password     : ${SETTINGS[admin_password]}"
		"- Title              : ${SETTINGS[title]}"

		"- MySQL Host         : ${SETTINGS[mysql_host]}"
		"- MySQL User         : ${SETTINGS[mysql_user]}"
		"- MySQL Password     : ${_mysql_password}"
		"- MySQL DB Name      : ${SETTINGS[mysql_db_name]}"
		"- MySQL Collate      : ${SETTINGS[mysql_collate]}"

		"- Testing            : ${SETTINGS[testing]}"
	)

	echo

	printf '%s\n' "${_settings[@]}"

}
# print_settings()



print_summary()
{

	local _prompt="${1}"

	# ----------------------------------------------------------------------------

	action_start "Summary"

	# ----------------------------------------------------------------------------

	echo

	printf '%s\n' "${SUMMARY[@]}"

	# ----------------------------------------------------------------------------

	if [ -n "${TIMER_TOTAL}" ]; then

		echo "- Performed in  : ${TIMER_TOTAL} sec"

	fi

	# ----------------------------------------------------------------------------

	if [ -n "${_prompt}" ]; then

		echo

		read -n1 -p "Press any key to continue..."

	fi

	# ----------------------------------------------------------------------------

	action_end

}
# print_summary()



action_start()
{

	local _repeat="80"

	# ----------------------------------------------------------------------------

	ACTION_CURRENT="${1}"

	# ----------------------------------------------------------------------------

	echo
	print_repeat_string "=" "${_repeat}"
	echo -e "${ACTION_CURRENT}"
	print_repeat_string "-" "${_repeat}"

}
# action_start()



action_end()
{

	local _action="${1:-${ACTION_CURRENT}}"
	local _repeat="80"

	# ----------------------------------------------------------------------------

	echo
	print_repeat_string "-" "${_repeat}"
	echo -e "${_action} - End"
	print_repeat_string "=" "${_repeat}"
	echo

}
# action_end()



sub_action_start()
{

	echo
	echo -e "- ${1}"

}
# sub_action_start()

# ==============================================================================
# PRINT RELATED - END
# ==============================================================================



# ==============================================================================
# EXIT RELATED - START
# ==============================================================================

exit_if_wrong_value()
{

	# get msg from param 1 - fallback to default

	local _msg="${1:-Wrong value}"

	# ----------------------------------------------------------------------------

	printf '\n%s\n\n' "# - ERROR: ${_msg}. Aborting." >&2

	# ----------------------------------------------------------------------------

	if [ -n "${ACTION_CURRENT}" ]; then

		action_end

	fi

	# ----------------------------------------------------------------------------

	exit 95

}
# exit_if_wrong_value()

# ==============================================================================
# EXIT RELATED - END
# ==============================================================================



# ==============================================================================
# PROMPT RELATED - START
# ==============================================================================

prompt_settings_value()
{

	local _msg="${1}"
	local _key="${2}"

	# turns echo off to hide input for cases such as entering passwords
	local _echo_off="${3}"

	local _default="${SETTINGS[$_key]}"
	local _val=""

	# ----------------------------------------------------------------------------

	# get val from user input - defaults to passed default

	if [ -n "${_echo_off}" ]; then

		read \
			-s -p "${_msg}" \
			-e -i "${_default}" _val

		echo

	else

		read \
			-p "${_msg}" \
			-e -i "${_default}" _val

	fi

	# ----------------------------------------------------------------------------

	# abort if nothing entered

	if [ -z "${_val}" ]; then

		exit_if_wrong_value "Nothing entered"

	fi

	# ----------------------------------------------------------------------------

	SETTINGS["${_key}"]="${_val}"

}
# prompt_settings_value()



prompt_proceed()
{

	local _msg="${1:-Do you want to proceed?}"

	# ----------------------------------------------------------------------------

	echo

	read -ep "${_msg} [Y]es, [N]o : " proceed

	case $proceed in

		[Yy]* )

			# all good

			# nothing to do the script will proceed

			;;

		# --------------------------------------------------------------------------

		[Nn]* )

			printf "\n%s\n" "Bye"

			action_end

			exit 95

			;;

		# --------------------------------------------------------------------------

		* )

			printf "\n%s\n" "Bye"

			action_end

			exit_if_wrong_value "Nothing entered, considering you don't want to proceed"

			;;

	esac

}
# prompt_proceed()

# ==============================================================================
# PROMPT RELATED - END
# ==============================================================================



# ==============================================================================
# MISC HELPERS - START
# ==============================================================================

timer_start()
{

	TIMER_START="`date +%s.%N`"
	TIMER_STOP=""
	TIMER_TOTAL=""

}
# timer_start()



timer_stop()
{

	if [ -n "${TIMER_START}" ]; then

		TIMER_STOP="`date +%s.%N`"
		TIMER_TOTAL=$(echo "${TIMER_STOP} - ${TIMER_START}" | bc)
		TIMER_START=""

	fi

}
# timer_stop()



get_domain_name_from_url()
{

	local _out="${1}"

	# ----------------------------------------------------------------------------

	echo "$_out" | sed -e 's|^[^/]*//||' -e 's|/.*$||'

}
# get_domain_name_from_url()



get_random_password()
{

	local _length="${1:-8}"

	# ----------------------------------------------------------------------------

	head /dev/urandom | tr -dc A-Za-z0-9 | head -c ${_length} ; echo ''

}
# get_random_password()



arr_join_by()
{

	local d=$1

	shift

	echo -n "$1"

	shift

	printf "%s" "${@/#/$d}"

}

# ==============================================================================
# MISC HELPERS - END
# ==============================================================================



# ==============================================================================
# SETTINGS RELATED - START
# ==============================================================================

settings_populate()
{

	action_start "Populating SETTINGS"

	# ----------------------------------------------------------------------------

	# @consider
	# default to working dir - set it using -d option

	#SETTINGS[dir]="${SETTINGS[dir]:-${SETTINGS[pwd]}}"

	# ----------------------------------------------------------------------------

	# sanitize dir

	SETTINGS[dir]=$(get_sanitized_dir_name "${SETTINGS[dir]}")

	# ----------------------------------------------------------------------------

	# some settings when testing

	if [ -n "${SETTINGS[testing]}" ]; then

		# set url

		SETTINGS[url]="${SETTINGS[url]:-$(join_path "http://bash.localhost" "${SCRIPT_INFO[file_name]%.*}")}"

		# --------------------------------------------------------------------------

		# admin pass

		SETTINGS[admin_password]="${SETTINGS[admin_password]:-pass}"

	fi

	# ----------------------------------------------------------------------------

	if [ -n "${SETTINGS[url]}" ]; then

		# urls

		SETTINGS[url]=$(join_path "${SETTINGS[url]}" "${SETTINGS[dir]}")
		SETTINGS[admin_url]=$(join_path "${SETTINGS[url]}" "${SETTINGS[wp_dir_name]}/wp-admin")
		SETTINGS[install_url]=$(join_path "${SETTINGS[admin_url]}" "install.php?step=2")

		# --------------------------------------------------------------------------

		SETTINGS[domain]="${SETTINGS[domain]:-$(get_domain_name_from_url ${SETTINGS[url]})}"

		# --------------------------------------------------------------------------

		SETTINGS[admin_username]="${SETTINGS[admin_username]:-admin}"
		SETTINGS[admin_password]="${SETTINGS[admin_password]:-$(get_random_password)}"

	fi

	# ----------------------------------------------------------------------------

	# if site title is empty, fallback to humanized dir name

	local _title

	if [ -z "${SETTINGS[dir]}" ] && [ -n "${SETTINGS[domain]}" ]; then

		_title="${SETTINGS[domain]}"

	else

		# in case dir is empty (when in current dir), use pwd basename

		_title="${SETTINGS[dir]:-$(basename ${SETTINGS[pwd]})}"

	fi

	SETTINGS[title]="${SETTINGS[title]:-$(get_humanized "${_title}")}"

	# ----------------------------------------------------------------------------

	settings_populate_mysql

	# ----------------------------------------------------------------------------

	sub_action_start "Review Populated Settings:"

	print_settings

	# ----------------------------------------------------------------------------

	# prompt user for confirmation

	prompt_proceed

	# ----------------------------------------------------------------------------

	# populate summary

	SUMMARY=(
		"- Date          : $(date '+%Y-%m-%d %T')"
		"- Directory     : ${SETTINGS[dir]}"
		"- DB Name       : ${SETTINGS[mysql_db_name]}"
		"- URL           : ${SETTINGS[url]}"
		"- Admin URL     : ${SETTINGS[admin_url]}"
		"- Admin Username: ${SETTINGS[admin_username]}"
		"- Admin Password: ${SETTINGS[admin_password]}"
		#"- Admin Password: ${SETTINGS[admin_password]} (don't forget to change it)"
	)

	# --------------------------------------------------------------------------

	action_end

}
# settings_populate()



settings_populate_mysql()
{

	SETTINGS[mysql_host]="${SETTINGS[mysql_host]:-localhost}"
	SETTINGS[mysql_user]="${SETTINGS[mysql_user]:-root}"
	SETTINGS[mysql_collate]="${SETTINGS[mysql_collate]:-CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci}"

	# ----------------------------------------------------------------------------

	# default db name based on domain and dir

	local _db_name=(
		"${SETTINGS[domain]}"
		"${SETTINGS[dir]}"
		"wp"
	)
	_db_name=$(arr_join_by "_" ${_db_name[@]})

	SETTINGS[mysql_db_name]="${SETTINGS[mysql_db_name]:-${_db_name}}"

	# ----------------------------------------------------------------------------

	# some settings when testing

	if [ -n "${SETTINGS[testing]}" ]; then

		# prefix db_name if we're testing - just so that it's easier to find when listing dbs

		if [ -n "${SETTINGS[mysql_db_name]}" ]; then

			SETTINGS[mysql_db_name]="aaa_${SETTINGS[mysql_db_name]}"

		fi

		# --------------------------------------------------------------------------

		# default mysql password to mysql user while testing

		SETTINGS[mysql_password]="${SETTINGS[mysql_password]:-${SETTINGS[mysql_user]}}"

	fi

	# ----------------------------------------------------------------------------

	# sanitize db name

	SETTINGS[mysql_db_name]=$(get_sanitized_mysql_db_name "${SETTINGS[mysql_db_name]}")

}
# settings_populate_mysql()

# ==============================================================================
# SETTINGS RELATED - END
# ==============================================================================



# ==============================================================================
# MYSQL RELATED - START
# ==============================================================================

mysql_db_exists()
{

	local _db_name="${1:-${SETTINGS[mysql_db_name]}}"

	# ----------------------------------------------------------------------------

	local _sql="SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${_db_name}'"

	# ----------------------------------------------------------------------------

	local _res=$(mysql \
	--user="${SETTINGS[mysql_user]}" \
	--password="${SETTINGS[mysql_password]}" \
	--execute="${_sql}")

	# @todo:
	#		mysql_execute is verbose which wouldn't make this work,
	#		need to find a way to pass verbose as param

	#local _exists=$(mysql_execute "${_sql}")

	# ----------------------------------------------------------------------------

	[[ -n "${_res}" ]]

}
# mysql_db_exists()



mysql_db_is_empty()
{

	local _db_name="${1:-${SETTINGS[mysql_db_name]}}"

	# ----------------------------------------------------------------------------

	local _sql="SELECT COUNT(DISTINCT TABLE_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '${_db_name}'"

	# ----------------------------------------------------------------------------

	# @notes
	#		use -ss or --silent and --skip-column-names to only get result without
	#		extra strings like column names

	local _res=$(mysql \
	--user="${SETTINGS[mysql_user]}" \
	--password="${SETTINGS[mysql_password]}" \
	--silent \
	--skip-column-names \
	--execute="${_sql}")

	# ----------------------------------------------------------------------------

	[[ $_res -eq 0 ]]

}
# mysql_db_is_empty()



mysql_db_create()
{

	action_start "MySQL Database Operations"

	# ----------------------------------------------------------------------------

	local _db_name="${SETTINGS[mysql_db_name]}"

	# ----------------------------------------------------------------------------

	sub_action_start "Checking if ${_db_name} Database Exists"

	if mysql_db_exists; then

		if ! mysql_db_is_empty; then

			exit_if_wrong_value "Database ${_db_name} exists and is not empty"

		fi

	fi

	# ----------------------------------------------------------------------------

	sub_action_start "Creating Database ${_db_name}"

	if mysql_db_is_empty; then

		local _sql="CREATE DATABASE IF NOT EXISTS ${_db_name} ${SETTINGS[mysql_collate]};"

		if [ -z "${SETTINGS[testing]}" ]; then

			mysql_execute "${_sql}"

		else

			# @todo: remove all this when dev done

			echo "-- mysql execute cmd: ${_sql}"

			mysql_execute "${_sql}"

		fi

	else

		echo "-- ${_db_name} already exists and is empty; we can proceed and use it"

	fi

	# ----------------------------------------------------------------------------

	action_end

}
# mysql_db_create()



mysql_execute()
{

	local _sql="${1}"

	# ----------------------------------------------------------------------------

	if [ -n "${_sql}" ]; then

		mysql \
		--host="${SETTINGS[mysql_host]}" \
		--user="${SETTINGS[mysql_user]}" \
		--password="${SETTINGS[mysql_password]}" \
		--execute="${_sql}" \
		-v

	fi

}
# mysql_execute()

# ==============================================================================
# MYSQL RELATED - END
# ==============================================================================



# ==============================================================================
# WP DIRECTORIES AND FILES RELATED - START
# ==============================================================================

wp_set_directories()
{

	action_start "Set WordPress Directories"

	# ----------------------------------------------------------------------------

	local _dirs=(
		"${SETTINGS[wp_dir_name]}"
		"${SETTINGS[wp_content_foldername]}"
		"${SETTINGS[wp_content_foldername]}/plugins"
		"${SETTINGS[wp_content_foldername]}/themes"
		".config"
	)
	local _dir
	local _file

	# ----------------------------------------------------------------------------

	for _dir in "${_dirs[@]}"; do

		sub_action_start "Checking ${_dir}"

		# --------------------------------------------------------------------------

		if [ ! -d "${_dir}" ]; then

			echo "-- mkdir -p ${_dir}"

			mkdir -p "${_dir}"

		else

			echo "-- found ${_dir}"

		fi

		# --------------------------------------------------------------------------

		_file="${_dir}/index.php"

		if [ ! -f "${_file}" ]; then

			echo "--- creating ${_file}"

			echo -e "<?php\n// Silence is golden." > ${_file}

		else

			echo "--- found ${_file}"

		fi

	done

	# ----------------------------------------------------------------------------

	action_end

}
# wp_set_directories()



wp_download()
{

	action_start "Download WordPress from ${SETTINGS[wp_source_url]}"

	# ----------------------------------------------------------------------------

	local _file_name=$(basename ${SETTINGS[wp_source_url]})
	local _file="${SCRIPT_INFO[dir_assets]}/${_file_name}"

	# ----------------------------------------------------------------------------

	# cmd options

	# -L/--location
	# is to follow redirects as during the time of writting,
	# ${SETTINGS[wp_source_url]} has a moved permanently 301 header

	local _cmd_options="--location --output ${_file}"

	# ----------------------------------------------------------------------------

	# -z/--time-cond will check if the local file is older than the remote

	if [ -e "${_file}" ]; then

		_cmd_options="${_cmd_options} --time-cond ${_file}"

	fi

	# ----------------------------------------------------------------------------

	sub_action_start "Downloading using the following command:"

	echo
	echo -e "curl \\"
	echo -e "--location \\"
	echo -e "--output ${_file} \\"
	echo -e "--time-cond ${_file} \\"
	echo -e "${SETTINGS[wp_source_url]}"
	echo

	curl ${_cmd_options} "${SETTINGS[wp_source_url]}"

	# ----------------------------------------------------------------------------

	action_end

}
# wp_download()



wp_extract()
{

	action_start "Extract WordPress to $(join_path ${SETTINGS[dir]} ${SETTINGS[wp_dir_name]})"

	# ----------------------------------------------------------------------------

	local _file_name=$(basename ${SETTINGS[wp_source_url]})
	local _file="${SCRIPT_INFO[dir_assets]}/${_file_name}"
	local	_to="${SETTINGS[wp_dir_name]}"

	# ----------------------------------------------------------------------------

	if [ ! -f "${_file}" ]; then

		exit_if_wrong_value "${_file} not found"

	fi

	# ----------------------------------------------------------------------------

	sub_action_start "Extracting using the following command:"

	echo
	echo -e "tar \\ \nxfz ${_file} \\ \n--directory=${_to} \\ \n--strip-components=1"

	tar xfz "${_file}" --directory="${_to}" --strip-components=1

	# ----------------------------------------------------------------------------

	if [ $? -ne 0 ]; then

		exit_if_wrong_value "Extraction failed"

	fi

	# ----------------------------------------------------------------------------

	action_end

}
# wp_extract()



wp_set_files()
{

	action_start "Set WordPress Directories and Files"

	# ----------------------------------------------------------------------------

	wp_set_files_config_dir

	# ----------------------------------------------------------------------------

	wp_set_files_root_dir

	# ----------------------------------------------------------------------------

	wp_set_files_themes_dir

	# ----------------------------------------------------------------------------

	action_end

}
# wp_set_files()



wp_add_salt_keys_to_config_file()
{

	local _file="${1}"
	local _keys_file="$(dirname ${_file})/.wp.keys"

	# ----------------------------------------------------------------------------

	# this should on be applicable if testing;
	# meaning, we should always fetch a fresh copy of salt keys

	if [ ! -f "${_keys_file}" ]; then

		wget -O "${_keys_file}" "${SETTINGS[wp_salt_keys_url]}"

	fi

	# ----------------------------------------------------------------------------

	# add after %AUTH_KEYS%
	# @todo: should replace it not add after it

	sed -i "/%AUTH_KEYS%/r ${_keys_file}" "${_file}"

	# ----------------------------------------------------------------------------

	# delete keys file

	if [ -z "${SETTINGS[testing]}" ] && [ -f "${_keys_file}" ]; then

		rm -f "${_keys_file}"

	fi

}
# wp_add_salt_keys_to_config_file()



wp_set_files_config_dir()
{

	local _templates_dir="${SCRIPT_INFO[dir_assets]}"
	local _dir=".config"
	local _file

	# ----------------------------------------------------------------------------

	sub_action_start "Setting ${_dir} dir files"

	# ----------------------------------------------------------------------------

	_file="${_dir}/config.php"

	if [ ! -f "${_file}" ]; then

		echo "-- creating ${_file}"

		# --------------------------------------------------------------------------

		sed \
		-e "s/%DB_NAME%/${SETTINGS[mysql_db_name]}/" \
		-e "s/%DB_USER%/${SETTINGS[mysql_user]}/" \
		-e "s/%DB_PASSWORD%/${SETTINGS[mysql_password]}/" \
		-e "s/%DB_HOST%/${SETTINGS[mysql_host]}/" \
		"${_templates_dir}/template_$(basename ${_file})" > "${_file}"

		# --------------------------------------------------------------------------

		echo "--- getting salt keys"

		wp_add_salt_keys_to_config_file "${_file}"

	else

		echo "-- found ${_file}"

	fi

	# ----------------------------------------------------------------------------

	_file="${_dir}/.gitignore"

	if [ ! -f "${_file}" ]; then

		echo "-- creating ${_file}"

		touch ${_file}

	else

		echo "-- found ${_file}"

	fi

	# ----------------------------------------------------------------------------

	_file="${_dir}/.htaccess"

	if [ ! -f "${_file}" ]; then

		echo "-- creating ${_file}"

		echo "Deny from all" > ${_file}

	else

		echo "-- found ${_file}"

	fi

}
# wp_set_files_config_dir()



wp_set_files_root_dir()
{

	local _templates_dir="${SCRIPT_INFO[dir_assets]}"
	local _file

	# ----------------------------------------------------------------------------

	sub_action_start "Setting root dir files"

	# ----------------------------------------------------------------------------

	_file="index.php"

	if [ ! -f "${_file}" ]; then

		echo "-- creating ${_file}"

		#cat "${_templates_dir}/template_${_file}" > "${_file}"

		sed \
		-e "s/%wp_dir_name%/${SETTINGS[wp_dir_name]}/" \
		"${_templates_dir}/template_${_file}" > "${_file}"

	else

		echo "-- found ${_file}"

	fi

	# ----------------------------------------------------------------------------

	_file="wp-config.php"

	local _site_package_name="${SETTINGS[title]}"

	if [ ! -f "${_file}" ]; then

		echo "-- creating ${_file}"

		sed \
		-e "s/%SITE_PACKAGE_NAME%/${_site_package_name}/" \
		-e "s/%wp_dir_name%/${SETTINGS[wp_dir_name]}/" \
		-e "s/%wp_content_foldername%/${SETTINGS[wp_content_foldername]}/" \
		"${_templates_dir}/template_${_file}" > "${_file}"

	else

		echo "-- found ${_file}"

	fi

	# ----------------------------------------------------------------------------

	_file=".htaccess"

	# @notes:
	#		this will set it to the root "/" of the domain which isn't always the case
	#		either find a way to auto get the path,
	#		or no need to do it as wp will create the file and
	#		set it based on insatllation location
	#
	#local _relative_path="/"
	local _relative_path="/${SETTINGS[dir]}/"

	if [ ! -f "${_file}" ]; then

		echo "-- creating ${_file}"

		sed \
		-e "s|%RELATIVE_PATH%|${_relative_path}|" \
		"${_templates_dir}/template_${_file}" > "${_file}"

	else

		echo "-- found ${_file}"

	fi

}
# wp_set_files_config_dir()



wp_set_files_themes_dir()
{

	local _theme="twentytwentytwo" # @todo: find a way to auto get latest theme
	local _from_dir="${SETTINGS[wp_dir_name]}/wp-content/themes/${_theme}"
	local _to_dir="${SETTINGS[wp_content_foldername]}/themes"

	# ----------------------------------------------------------------------------

	sub_action_start "Copying ${_theme} theme to ${_to_dir}"

	cp -r "${_from_dir}" "${_to_dir}"

}
# wp_set_files_themes_dir()



set_permissions()
{

	# default to settings dir

	local _path="${1:-${SETTINGS[dir]}}"

	# ----------------------------------------------------------------------------

	action_start "Setting Permissions to ${_path}"

	# ----------------------------------------------------------------------------

	local _user="${USER}"

	if is_root; then

		_user="${SUDO_USER}"

	fi

	# ----------------------------------------------------------------------------

	sub_action_start "Changing Owner to \"${_user}\", Group to \"www-data\", and Giving Group Same Pernissions as Owner"

	if [ "${SETTINGS[dir]}" == "${_path}" ]; then

		_path="."

	fi

	sudo chown -R "${_user}":"www-data" "${_path}" && \
	sudo chmod -R g=u "${_path}"

	if [ $? -eq 0 ]; then

		echo "-- done"

	else

		# reminder to change group and permissions if the script was ran as non sudo

		echo
		echo "# NOTES:"
		echo
		echo -e "  I couldn't run the commands 'chown' and 'chmod' as sudo."
		echo
		echo -e "  If you want to change the group to \"www-data\","
		echo -e "  run the following commands:"
		echo -e "  sudo chgrp -R \"www-data\" ${SETTINGS[dir]} && sudo chmod -R g=u ${SETTINGS[dir]}"

	fi

	# ----------------------------------------------------------------------------

	action_end

}
# set_permissions()

# ==============================================================================
# WP DIRECTORIES AND FILES RELATED - END
# ==============================================================================



# ==============================================================================
# INSTALLATION - START
# ==============================================================================

install()
{

	if ! is_mysql_installed || [ -z "${SETTINGS[mysql_db_name]}" ] || [ -z "${SETTINGS[mysql_password]}" ]; then

		return

	fi

	# ----------------------------------------------------------------------------

	mysql_db_create

	# ----------------------------------------------------------------------------

	if ! is_curl_installed || [ -z "${SETTINGS[install_url]}" ]; then

		return

	fi

	# ----------------------------------------------------------------------------

	install_wp

}
# install()



install_wp()
{

	action_start "Installing WordPress"

	# ----------------------------------------------------------------------------

	local _url="${SETTINGS[install_url]}"
	local _param=$(get_install_param)
	local _cmd="curl \\ \n--fail \\ \n--silent \\ \n--data ${_param} \\ \n${_url}"

	sub_action_start "Installing using curl:"

	echo
	echo -e "${_cmd}"

	curl --fail --silent --data "${_param}" "${_url}" > /dev/null

	if [ $? -ne 0 ]; then

		exit_if_wrong_value "Installation failed"

	fi

	# ----------------------------------------------------------------------------

	install_wp_usermeta

	# ----------------------------------------------------------------------------

	install_wp_permalinks

	# ----------------------------------------------------------------------------

	action_end

}
# install_wp()



get_install_param()
{

	local _out=(
		"weblog_title=${SETTINGS[title]}"
		"user_name=${SETTINGS[admin_username]}"
		"admin_password=${SETTINGS[admin_password]}"
		"admin_password2=${SETTINGS[admin_password]}"
		"admin_email=${SETTINGS[admin_username]}@${SETTINGS[domain]}"
		"blog_public=0"
	)

	# ----------------------------------------------------------------------------

	local _saved_ifs=$IFS	# save current ifs
	IFS="&"								# set new delimiter to &
	_out="${_out[*]}"			# join the array with newly set delimiter
	IFS=$_saved_ifs				# restore ifs

	# ----------------------------------------------------------------------------

	echo "${_out}"

}
# get_install_param()



install_wp_usermeta()
{

	sub_action_start "Setting up user meta"

	# ----------------------------------------------------------------------------

	local metaboxhidden="
		array(
			'dashboard_activity',
			'dashboard_quick_press',
			'dashboard_primary',
			'dashboard_site_health'
		)
	"
	metaboxhidden=$(php -r "echo serialize(${metaboxhidden});")

	# ----------------------------------------------------------------------------

	local _sql="
		UPDATE ${SETTINGS[mysql_db_name]}.wp_usermeta SET meta_value = 0 WHERE meta_key = 'show_welcome_panel' AND user_id = 1;
		UPDATE ${SETTINGS[mysql_db_name]}.wp_usermeta SET meta_value = 'false' WHERE meta_key = 'show_admin_bar_front' AND user_id = 1;
		INSERT INTO ${SETTINGS[mysql_db_name]}.wp_usermeta (user_id,meta_key,meta_value) VALUES (1,'metaboxhidden_dashboard','${metaboxhidden}');
		INSERT INTO ${SETTINGS[mysql_db_name]}.wp_usermeta (user_id,meta_key,meta_value) VALUES (1,'wp_user-settings','editor=html');
	"

	# ----------------------------------------------------------------------------

	# to set default admin color use:
	#UPDATE ${SETTINGS[mysql_db_name]}.wp_usermeta SET meta_value = 'coffee' WHERE meta_key = 'admin_color' AND user_id = 1;

	# ----------------------------------------------------------------------------

	mysql_execute "${_sql}"

}
# install_wp_usermeta()



install_wp_permalinks()
{

	sub_action_start "Setting up permalinks"

	# ----------------------------------------------------------------------------

	local _sql="
		UPDATE ${SETTINGS[mysql_db_name]}.wp_options SET option_value = '/%postname%/' WHERE option_name = 'permalink_structure';
	"

	# ----------------------------------------------------------------------------

	mysql_execute "${_sql}"

}
# install_wp_permalinks()

# ==============================================================================
# INSTALLATION - END
# ==============================================================================



# ==============================================================================
# SCRIPT OPTIONS - START
# ==============================================================================

script_options_print_help()
{

	echo
	echo "usage: wp_install.sh [OPTION]"
	echo
	echo "OPTIONS:"
	echo -e "  -u      Site URL (Required if not testing)"
	echo -e "  -p      MySQL password (Required if not testing)"
	echo -e "  -b      MySQL Database name"
	echo -e "  -d      Directory where to install WordPress"
	echo -e "          Must be relative to URL such as 'relative/path'"
	echo -e "          If left empty, the current working directory will be used"
	echo -e "  -t      Testing - when set special execution takes place"
	echo -e "  -h      Show this message"
	echo
	echo "Here's an example:"
	echo "bash wp_install.sh \\"
	echo "-u http://domain.tld \\"
	echo "-d relative/path \\"
	echo "-p MySQLPassword"
	#print_green "Here's an example:"
	#print_yellow echo "bash wp_install.sh \\"
	#print_gray echo "-d relative/path \\"
	#print_magenta echo "-u http://domain.tld \\"
	#print_cyan "-p MySQLPassword"
	echo

}
# script_options_print_help()



script_options_set()
{

	while getopts ":htb:p:u:d:" OPTION
	do
		case "${OPTION}" in

			b )

				SETTINGS["mysql_db_name"]=$OPTARG

				;;

			# ------------------------------------------------------------------------

			p )

				SETTINGS["mysql_password"]=$OPTARG

				;;

			# ------------------------------------------------------------------------

			u )

				SETTINGS["url"]=$OPTARG

				;;

			# ------------------------------------------------------------------------

			d )

				SETTINGS["dir"]=$OPTARG

				;;

			# ------------------------------------------------------------------------

			t )

				SETTINGS["testing"]="y"

				;;

			# ------------------------------------------------------------------------

			h )

				script_options_print_help

				exit 0

				;;

			# ------------------------------------------------------------------------

			\? )

				echo "Invalid option: -$OPTARG" >&2

				script_options_print_help

				exit 1

				;;

			# ------------------------------------------------------------------------

			: )

				echo "Missing option argument for -$OPTARG" >&2

				exit 1

				;;

			# ------------------------------------------------------------------------

			* )

				echo "Unimplemented option: -$OPTARG" >&2

				exit 1

				;;

		esac
	done

}
# script_options_set()

# ==============================================================================
# SCRIPT OPTIONS - END
# ==============================================================================



# ==============================================================================
# FUNCTIONS - START
# ==============================================================================

check_system_requirements()
{

	if ! is_curl_installed; then

		exit_if_wrong_value "curl is required"

	fi

	# ----------------------------------------------------------------------------

	if ! is_tar_installed; then

		exit_if_wrong_value "tar is required"

	fi

	# ----------------------------------------------------------------------------

	if ! is_mysql_installed; then

		exit_if_wrong_value "mysql is required"

	fi

	# ----------------------------------------------------------------------------

	if ! is_php_installed; then

		exit_if_wrong_value "php is required"

	fi

}
# check_system_requirements



check_required_settings()
{

	if [ -n "${SETTINGS[testing]}" ]; then

		return

	fi

	# ----------------------------------------------------------------------------

	# required settings if not testing:
	#	- url
	#	- mysql password
	#	- dir ...? maybe can work based on using the current dir
	#	- db_name ...? can be auto generated based on domain and dir

	# ----------------------------------------------------------------------------

	if [ -z "${SETTINGS[url]}" ]; then

		echo
		prompt_settings_value "Enter URL, and press [ENTER] :" "url"

	fi

	# ----------------------------------------------------------------------------

	if ! is_valid_url "${SETTINGS[url]}"; then

		exit_if_wrong_value "'${SETTINGS[url]}' doesn't seem like a valid URL. A valid URL would look something like http://domain.tld/any/path"

	fi

	# ----------------------------------------------------------------------------

	if [ -z "${SETTINGS[mysql_password]}" ]; then

		echo
		prompt_settings_value \
			"Enter MySQL Password, and press [ENTER] :" \
			"mysql_password" \
			"y"

	fi

}
# check_required_settings()



check_dir()
{

	action_start "Checking directory"

	# ----------------------------------------------------------------------------

	# default to pwd

	local _dir="${SETTINGS[dir]:-${SETTINGS[pwd]}}"

	##if [ "${SETTINGS[dir]}" != "${SETTINGS[pwd]}" ]; then
	if [ "${_dir}" != "${SETTINGS[pwd]}" ]; then

		if [ ! -d "${SETTINGS[dir]}" ]; then

			sub_action_start "Creating ${SETTINGS[dir]}"

			mkdir -p "${SETTINGS[dir]}"

			# ------------------------------------------------------------------------

			# change owner to sudo user in case the script was run as sudo
			# @notes:
			#		the following will only set the dir but wouldn't set any created parents
			#		so this isn't needed as it's done anyway in set_permissions()
			#		the only thing i can think of for dealing with this is to use `su`
			#		and switch to the sudo user before mkdir and then switch back to sudo
			#		which needs to deal with cd into dir...
			#		not implementing it for now

			#if [ "${UID}" -eq 0 ]; then

				#su "${SUDO_USER}" -c mkdir -p "${SETTINGS[dir]}"

			#else

				#mkdir -p "${SETTINGS[dir]}"

			#fi

		else

			sub_action_start "Found ${SETTINGS[dir]}"

		fi

		# --------------------------------------------------------------------------

		sub_action_start "cd into ${SETTINGS[dir]}"

		cd "${SETTINGS[dir]}"

	else

		sub_action_start "Installation will be done in current directory:"

		echo "-- ${_dir}"

	fi

	# ----------------------------------------------------------------------------

	action_end

}
# check_dir



run_it()
{

	check_system_requirements

	# ----------------------------------------------------------------------------

	script_options_set $@

	# ----------------------------------------------------------------------------

	check_required_settings

	# ----------------------------------------------------------------------------

	settings_populate

	# ----------------------------------------------------------------------------

	#if [ -n "${SETTINGS[testing]}" ]; then

		#action_start "SCRIPT_INFO and SETTINGS"

		#sub_action_start "SCRIPT_INFO:"

		#print_script_info

		#sub_action_start "SETTINGS:"

		#print_settings

		#action_end

	#fi

	# ----------------------------------------------------------------------------

	timer_start

	# ----------------------------------------------------------------------------

	check_dir

	# ----------------------------------------------------------------------------

	wp_set_directories

	# ----------------------------------------------------------------------------

	wp_download

	# ----------------------------------------------------------------------------

	wp_extract

	# ----------------------------------------------------------------------------

	wp_set_files

	# ----------------------------------------------------------------------------

	set_permissions

	# ----------------------------------------------------------------------------

	install

	# ----------------------------------------------------------------------------

	timer_stop

	# ----------------------------------------------------------------------------

	print_summary

	# ----------------------------------------------------------------------------

	exit

}
# run_it()

# ==============================================================================
# FUNCTIONS - END
# ==============================================================================



# ==============================================================================
# EXECUTION - START
# ==============================================================================

run_it $@

# ==============================================================================
# EXECUTION - END
# ==============================================================================

