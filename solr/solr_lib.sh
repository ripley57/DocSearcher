function solr_init()
{
    local _pwd="$(utils_script_dir "$BASH_SOURCE")"
    #echo "solr_init: _pwd=$_pwd"
    DOCSEARCH_SOLR_VERSION=7.3.1
    DOCSEARCH_SOLR_PORT=8983
    DOCSEARCH_SOLR_DIR="${_pwd}"
    DOCSEARCH_SOLR_BIN_DIR="${_pwd}/solr-7.3.1/bin"
    DOCSEARCH_SOLR_SERVER_DIR="${_pwd}/solr-7.3.1/server"
    DOCSEARCH_SOLR_LOGS_DIR="${_pwd}/solr-7.3.1/server/logs"
    DOCSEARCH_SOLR_CONFIGSET_DIR="${_pwd}/solr-7.3.1/server/solr/configsets"
    DOCSEARCH_SOLR_MY_CONFIGSET_DIR="${_pwd}/myconfigsets"
    DOCSEARCH_SOLR_DOWNLOAD_ZIP_URL=https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.zip
    DOCSEARCH_SOLR_DOWNLOAD_ZIP_FILENAME=solr-7.3.1.zip
    # Store downloads here.
    DOCSEARCH_SOLR_DOWNLOAD_TEMP_DIR="${_pwd}/../temp"
    # Extract the zip to this directory.
    DOCSEARCH_SOLR_DOWNLOAD_EXTRACT_TO_DIR=$DOCSEARCH_SOLR_DIR
    # The directory we expect to see after extraction.
    DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR=$DOCSEARCH_SOLR_DOWNLOAD_EXTRACT_TO_DIR/solr-7.3.1
}
solr_init


function solr_version()
{
    echo $DOCSEARCH_SOLR_VERSION
}


function solr_install()
{
    if [ "$1" == "reinstall" ]; then
        if ! utils_are_you_sure "Re-install Solr? (y/n): "; then
            return
        fi
	solr_stop
        solr_uninstall
    fi
    echo "Installing Solr ..."
    utils_download_and_install_zip \
    "$DOCSEARCH_SOLR_DOWNLOAD_ZIP_URL" \
    "$DOCSEARCH_SOLR_DOWNLOAD_TEMP_DIR" \
    "$DOCSEARCH_SOLR_DOWNLOAD_ZIP_FILENAME" \
    "$DOCSEARCH_SOLR_DOWNLOAD_EXTRACT_TO_DIR" \
    "$DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR"
    solr_install_myconfigsets
    solr_apply_fixes
}


function solr_apply_fixes()
{
    echo "Applying Solr fixes ..."
    sed -i '711,711s/< <(/ <\$(/' "$DOCSEARCH_SOLR_BIN_DIR/solr"
}

function solr_install_myconfigsets()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    local _configset_zips
    IFS=$'\n' _configset_zips=( $(find "$DOCSEARCH_SOLR_MY_CONFIGSET_DIR" -maxdepth 1 -type f -iname "*.zip" -exec sh -c 'echo ${1##*/}' _ {} \; ) )

    if [ ${#_configset_zips[*]} -gt 0 ]; then
        echo "Installing custom configsets ..."
    fi

    local _z
    for _z in "${_configset_zips[@]}"
    do
        local _extracted_dir="${_z%%.*}"
        utils_install_zip "$DOCSEARCH_SOLR_MY_CONFIGSET_DIR/$_z" "$DOCSEARCH_SOLR_CONFIGSET_DIR" "$DOCSEARCH_SOLR_CONFIGSET_DIR/$_extracted_dir"
    done
}


function solr_uninstall()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    echo  "Uninstalling Solr ..."
    local _datestamp=$(utils_get_datestamp)
    # Rename the Solr directory (rather than deleting it).
    if [ -d "$DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR" ]; then
         mv "$DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR" "${DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR}_${_datestamp}"
    fi
}


function solr_search_core()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi
    local _core=$1
    utils_assert_arg "core" "$_core" "solr_search_core"
    echo "Launching browser to search core \"$_core\" ..."
    utils_open_url "http://localhost:8983/solr/$_core/browse"
}


function solr_start()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    if [ $(solr_state) == RUNNING ]; then
        echo "solr_start: Already running!"
	return
    fi

    echo "Starting Solr..."
    utils_assert_var "DOCSEARCH_SOLR_BIN_DIR" "solr_start"
    (cd "${DOCSEARCH_SOLR_BIN_DIR}" && sh ./solr start -m 1g 2>&1 >/dev/null) 2>&1 >/dev/null

    if [ $(solr_state) == RUNNING ]; then
        echo "Solr successfully started."
    else
        echo "solr_start: Failed to start Solr!"
	return
    fi
}


function solr_stop()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    if [ $(solr_state) == STOPPED ]; then
        echo "solr_start: Already stopped!"
	return
    fi

    echo "Stopping Solr..."
    utils_assert_var "DOCSEARCH_SOLR_BIN_DIR" "solr_stop"
    (cd "${DOCSEARCH_SOLR_BIN_DIR}" && sh ./solr stop -all 2>&1 >/dev/null) 2>&1 >/dev/null

    if [ $(solr_state) == STOPPED ]; then
        echo "Solr successfully stopped."
    else
        echo "solr_start: Failed to stop Solr!"
	return
    fi
}


function solr_restart()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    if [ $(solr_state) == RUNNING ]; then
        solr_stop
    fi

    if [ $(solr_state) != STOPPED ]; then
        echo "solr_restart: Failed to stop Solr!"
	return
    fi

    echo "Restarting Solr..."
    utils_assert_var "DOCSEARCH_SOLR_BIN_DIR" "solr_restart"
    (cd "$DOCSEARCH_SOLR_BIN_DIR" && sh ./solr restart -p $DOCSEARCH_SOLR_PORT -m 1g 2>&1 >/dev/null) 2>&1 >/dev/null

    if [ $(solr_state) != RUNNING ]; then
        echo "solr_restart: Failed to start Solr!"
	return
    fi
}


function solr_state()
{
    if [ -z "$DOCSEARCH_SOLR_BIN_DIR" ] || [ ! -e "$DOCSEARCH_SOLR_BIN_DIR" ]; then
        echo "NOT-INSTALLED"
	return
    fi
    local _ret=STOPPED
    netstat -an | grep -i "listen" | grep :8983 >/dev/null && _ret=RUNNING
    echo $_ret
}


function solr_installed_state()
{
    local _ret=NOT-INSTALLED
    [ -e "$DOCSEARCH_SOLR_BIN_DIR" ] && _ret=INSTALLED
    echo $_ret
}


function solr_configsets()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    local _configset_array
    utils_assert_var "DOCSEARCH_SOLR_CONFIGSET_DIR" "solr_configsets"
    IFS=$'\n' _configset_array=( $(find "$DOCSEARCH_SOLR_CONFIGSET_DIR" -maxdepth 1 -type d -exec sh -c 'echo ${1##*/}' _ {} \; | grep -v configsets | sort) )

    # Note: The caller of this function calls it like this:
    # eval $(solr_configsets)
    # This recreates the array (i.e. with same name) on the client side.
    # (See https://stackoverflow.com/questions/10582763/how-to-return-an-array-in-bash-without-using-globals)
    declare -p _configset_array
}


function solr_cores()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    local _core_array
    utils_assert_var "DOCSEARCH_SOLR_SERVER_DIR" "solr_cores"
    IFS=$'\n' _core_array=( $(find "$DOCSEARCH_SOLR_SERVER_DIR/solr" -maxdepth 1 -type d -exec sh -c 'echo ${1##*/}' _ {} \; | grep -v -E 'configsets|solr' | sort) )

    # Note: The caller of this function calls it like this:
    # eval $(solr_cores)
    # This recreates the array (i.e. with same name) on the client side.
    # (See https://stackoverflow.com/questions/10582763/how-to-return-an-array-in-bash-without-using-globals)
    declare -p _core_array
}

function solr_delete_index()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    local _core=$1
    utils_assert_arg "core" "$_core" "solr_delete_index"
    utils_assert_var "DOCSEARCH_SOLR_SERVER_DIR" "solr_delete_index"
    local _core_dir="${DOCSEARCH_SOLR_SERVER_DIR}/solr/$_core"
    if [ ! -d "$_core_dir" ]; then
        echo "solr_delete_index: No such core: $_core !"
	return
    fi
    if [ "$(solr_state)" != "RUNNING" ]; then
        echo "solr_delete_index: Solr must not be running!"
	return
    fi

    # Delete the core index directory.
    rm -fr "$_core_dir/data"
    # Recreate an empty "data" directory.
    mkdir "$_core_dir/data" 
}


function solr_create_core()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi
    local _core=$1
    local _configset=$2
    utils_assert_arg "core" "$_core" "solr_create_core"
    utils_assert_arg "configset" "$_configset" "solr_create_core"
    utils_assert_var "DOCSEARCH_SOLR_BIN_DIR" "solr_create_core"
    echo "Creating core \"$_core\" using configset \"$_configset\" ..."
    (cd "$DOCSEARCH_SOLR_BIN_DIR" && sh ./solr create_core -c "$_core" -d "$_configset")
}


function solr_delete_core()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi
    local _core=$1
    utils_assert_arg "core" "$_core" "solr_delete_core"
    utils_assert_var "DOCSEARCH_SOLR_BIN_DIR" "solr_delete_core"
    echo "Deleting core \"$_core\" ..."
    (cd "$DOCSEARCH_SOLR_BIN_DIR" && sh ./solr delete -c "$_core")
}


function solr_funcs()
{
    set | grep '^solr_'
}


function solr_import_sample_docs()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    if [ "$(solr_state)" != "RUNNING" ]; then
        echo "Solr must be running!"
	return
    fi

    local _core=$1
    utils_assert_arg "core" "$_core" "solr_import_sample_docs"
    java -Durl="http://localhost:8983/solr/$_core/update" -jar "$DOCSEARCH_SOLR_DIR/demo/post.jar" "$DOCSEARCH_SOLR_DIR/demo/add.xml"
}
