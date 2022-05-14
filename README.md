# WP Install

> Quick way to install WordPress


## Usage

```sh
# install

$ bash wp_install.sh

# ------------------------------------------------------------------------------

# help

$ ./wp_install.sh -h

# output:
usage: wp_install.sh [OPTION]

OPTIONS:
  -u      Site URL (Required if not testing)
  -p      MySQL password (Required if not testing)
  -b      MySQL Database name
  -d      Directory where to install WordPress
          Must be relative to URL such as 'relative/path'
          If left empty, the current working directory will be used
  -t      Testing - when set special execution takes place
  -h      Show this message

Here's an example:
bash wp_install.sh \
-u http://domain.tld \
-d relative/path \
-p MySQLPassword

```


### Add as bash alias

```sh
# make it executable

$ chmod +x /path/to/wp_install.sh

# ------------------------------------------------------------------------------

# add to .bash_aliases

$ cat >> "${HOME}/.bash_aliases" <<EOL

# custom alias - added on $(date '+%Y-%m-%d %H:%M:%S')
alias wp_install='/path/to/wp_install.sh'
EOL

# ------------------------------------------------------------------------------

# use it as follows

wp_install [options]

```


## License

MIT © [webmasterish](https://webmasterish.com)
