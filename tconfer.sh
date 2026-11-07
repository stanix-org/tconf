# install tconf and tmake files

tconfer_error () {
	echo "tconfer :" "$@" >&2
}

tconfer_help () {
	echo "usage : $0 OPTIONS [DIRECTORIES]
Install tconf and tmake.
options :
--install : install tconf and tmake into the directories
--infos   : print infos about tconf and tmake into the directories
--force   : force install tconf and tmake, even if the installed version is newer
--verbose : print updated and unupdated files
--version : print the bundled tconf and tmake version
--help    : show this help and exit"
}

tconfer_get_tconf_version () {
	if test -f "tconf.sh" ; then
		. ./tconf.sh
		echo "$TCONF_VERSION"
	else
		echo "0.0.0"
	fi
}

tconfer_get_tmake_version () {
	if test -f "make/tmake-init.mk" ; then
		echo "TMAKE_DIR = $PWD/make
include \$(TMAKE_DIR)/tmake-init.mk

ifeq (\$(TMAKE_VERSION),)
all :
	@echo "0.1.0"
else
all :
	@echo \$(TMAKE_VERSION)
endif" | make -f -
	else
		echo "0.0.0"
	fi
}

tconfer_is_version_newer () {
	MAJOR1="$(echo "$1" | cut -d "." -f1)"
	MINOR1="$(echo "$1" | cut -d "." -f2)"
	PATCH1="$(echo "$1" | cut -d "." -f3)"
	MAJOR2="$(echo "$2" | cut -d "." -f1)"
	MINOR2="$(echo "$2" | cut -d "." -f2)"
	PATCH2="$(echo "$2" | cut -d "." -f3)"
	test "$MAJOR1" -gt "$MAJOR2" && return 0
	test "$MAJOR1" -lt "$MAJOR2" && return 1
	test "$MINOR1" -gt "$MINOR2" && return 0
	test "$MINOR1" -lt "$MINOR2" && return 1
	test "$PATCH1" -gt "$PATCH2" && return 0
	test "$PATCH1" -lt "$PATCH2" && return 1
	return 1
}

tconfer_install_file () {
	if test "$#" != "4" ; then
		tconfer_error "usage : tconf_install_file FILE DEST VERSION INSTALLED-VERSION"
		return 1
	fi
	if test "$FORCE" = "yes" || tconfer_is_version_newer "$3" "$4" ; then
		tconfer_verbose "installing file '$2'"
		cp "$1" "$2"
	else
		tconfer_verbose "skiping file '$2'"
	fi
}

tconfer_install () {
	tconfer_install_file "$TCONFER_DIR/tconf.sh" "tconf.sh" "$TCONF_VERSION" "$(tconfer_get_tconf_version)"

	# install tmake files
	MK_FILES="$(find -name "[Mm]akefile" -or -name "[Mm]akefile.in" -or -name "*.mk")"
	INSTALLED_TMAKE_VERSION="$(tconfer_get_tmake_version)"
		
	# keep this in dependencies order
	for FILE in \
		"tmake-init.mk" \
		"tmake-version.mk" \
		"tmake-prog.mk" \
		"tmake-lib.mk" \
		"tmake-locale.mk" \
		"tmake-incs.mk" \
		"tmake-files.mk" \
		"tmake-subdir.mk" \
		"tmake-compile.mk" \
	; do
		if grep "include \$(TMAKE_DIR)/$FILE" $MK_FILES > /dev/null; then
			mkdir -p "make"
			tconfer_install_file "$TCONFER_DIR/make/$FILE" "make/$FILE" "$TMAKE_VERSION" "$INSTALLED_TMAKE_VERSION"
			MK_FILES="$MK_FILES make/$FILE"
		fi
	done
}

tconfer_print_infos () {
	echo "current tconf version : $(tconfer_get_tconf_version)"
	echo "current tmake version : $(tconfer_get_tmake_version)"
}

tconfer_verbose () {
	true
}

# determinate tconf and tmake versions
TCONF_VERSION="$(cd "$TCONFER_DIR" && tconfer_get_tconf_version)"
TMAKE_VERSION="$(cd "$TCONFER_DIR" && tconfer_get_tmake_version)"

INSTALL="no"
FORCE="no"
INFOS="no"

for I in "$@" ; do
	case "$I" in
		--install)
			INSTALL="yes"
			shift
			;;
		--force)
			FORCE="yes"
			shift
			;;
		--verbose)
			tconfer_verbose () { echo "$@" ; }
			shift
			;;
		--infos)
			INFOS="yes"
			shift
			;;
		--version)
			echo "tconf version : $TCONF_VERSION"
			echo "tmake version : $TMAKE_VERSION"
			exit 0
			;;
		--help)
			tconfer_help
			exit 0
			;;
		--*)
			tconfer_error "unkonwn option '$1'"
			exit 1
			;;
		*)
			break
			;;
	esac
done

if test "$#" = "0" ; then
	set -- "."
fi

for DIR in "$@" ; do
	if test "$INFOS" = "yes" ; then
		(cd "$DIR" && tconfer_print_infos) || return 1
	fi
	if test "$INSTALL" = "yes" ; then
		(cd "$DIR" && tconfer_install) || return 1
	fi
done
