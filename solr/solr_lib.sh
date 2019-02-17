function solr_init()
{
    local _pwd="$(utils_script_dir "$BASH_SOURCE")"
    #echo "solr_init: _pwd=$_pwd"
    DOCSEARCH_SOLR_VERSION=7.3.1
    DOCSEARCH_SOLR_PORT=8983
    DOCSEARCH_SOLR_DIR="${_pwd}"
    DOCSEARCH_SOLR_BIN_DIR="${_pwd}/solr-7.3.1/bin"
    DOCSEARCH_SOLR_SERVER_DIR="${_pwd}/solr-7.3.1/server"
    DOCSEARCH_SOLR_DIST_DIR="${_pwd}/solr-7.3.1/dist"
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
    # Solr log files.
    DOCSEARCH_SOLR_LOGS=( $DOCSEARCH_SOLR_SERVER_DIR/logs/solr.log )
    # Stores persisted values.
    DOCSEARCH_SOLR_PERSISTED_VALUES="$DOCSEARCH_SOLR_DIR/.persisted_values"
}
solr_init


function solr_version()
{
    echo $DOCSEARCH_SOLR_VERSION
}


function solr_gethostname()
{
    local _hostname=
    _hostname="$(utils_get_persisted_value "$DOCSEARCH_SOLR_PERSISTED_VALUES" "hostname")"
    if [ -z "$_hostname" ] || [ "$_hostname" = "undefined" ]; then
        echo "localhost"
    else
        echo "$_hostname"
    fi
}


function solr_sethostname()
{
    local _hostname=$1
    utils_assert_var "_hostname" "$_hostname" "solr_sethostname"
    utils_set_persisted_value "$DOCSEARCH_SOLR_PERSISTED_VALUES" "hostname" "$_hostname"
}


function solr_isRemote()
{
    [ "$(solr_gethostname)" != "localhost" ]
}


function solr_install()
{
    if solr_isRemote; then
        echo 
        echo "Sorry, Solr is running remotely [$(solr_gethostname)]."
        echo "Reset the Solr hostname to locahost if you want"
        echo "to install Solr locally!"
        echo
        return
    fi

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
    solr_install_overlay
    solr_apply_fixes
    solr_install_myconfigsets
}


function solr_apply_configset_fixes()
{
    # My configset "my-configset-solr-731" included an edit
    # to the Velocity file "richtext_doc.vm" to replace "file:///"
    # with "appurl:///" (see line 82). This was so that we could
    # launch the native application of the file when the user 
    # clicked on the link. This only works on Windows, because we
    # there we can edit the Registry, to workaround the known web 
    # browser security feature that prevents a web page loaded from
    # a web server from opening local files, i.e. "file:///...".
    # The change below prevents "file:///" from being replaced
    # with "appurl:///" on our Linux install here.
    sed -i '82,82s/file:/xxxfile:/' "$DOCSEARCH_SOLR_CONFIGSET_DIR/my-configset-solr-731/conf/velocity/richtext_doc.vm"
    # Note: I have not yet found a working Linux equivalent to the
    # use of "appurl:///" on Windows. There exists a Firefox addon
    # named "Local Filesystem Links", but I cannot get this to work
    # (as of 12-02-2019). I tried with both Lubuntu (LXDE ui) and 
    # Ubuntu (Gnome), but it fails with an "ERROR undefined" pop-up
    # when I click on a link. For more details on the addon:
    # https://addons.mozilla.org/en-GB/firefox/addon/local-filesystem-links/
}

function solr_install_overlay()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    echo "Installing our Solr overlay ..."

    # Install our rebuilt solr-velocity jar with LinkTool support.
    # (https://www.cyberciti.biz/faq/explain-brace-expansion-in-cp-mv-bash-shell-commands/)
    mv "$DOCSEARCH_SOLR_DIST_DIR/solr-velocity-7.3.1.jar"{,.before_overlay}
    cp "$DOCSEARCH_SOLR_DIR/overlays/solr-731/solr-velocity-7.3.1.jar" "$DOCSEARCH_SOLR_DIST_DIR/"

    # Add missing document type icons which are based on file extension.
    # Note: Copy doc.png to docx.png in the same directory.
    cp "$DOCSEARCH_SOLR_SERVER_DIR/solr-webapp/webapp/img/filetypes/doc.png" "$DOCSEARCH_SOLR_SERVER_DIR/solr-webapp/webapp/img/filetypes/docx.png"
    cp "$DOCSEARCH_SOLR_SERVER_DIR/solr-webapp/webapp/img/ico/mail.png" "$DOCSEARCH_SOLR_SERVER_DIR/solr-webapp/webapp/img/filetypes/msg.png"
}


function solr_apply_fixes()
{
    echo "Applying our Solr fixes ..."

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
        echo "Installing our configsets ..."
    fi

    local _z
    for _z in "${_configset_zips[@]}"
    do
        local _extracted_dir="${_z%%.*}"
        utils_install_zip "$DOCSEARCH_SOLR_MY_CONFIGSET_DIR/$_z" "$DOCSEARCH_SOLR_CONFIGSET_DIR" "$DOCSEARCH_SOLR_CONFIGSET_DIR/$_extracted_dir"
    done

    solr_apply_configset_fixes
}


function solr_uninstall()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    echo  "Uninstalling Solr ..."
    local _datestamp=$(utils_get_datestamp)
    if [ -d "$DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR" ]; then
         mv "$DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR" "${DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR}_${_datestamp}"
	 # Disk space can be a problem, so lets really delete it.
	 rm -fr "${DOCSEARCH_SOLR_DOWNLOAD_EXTRACTED_DIR}_${datestamp}"
    fi
}


function solr_search_core()
{
    local _core=$1
    utils_assert_arg "core" "$_core" "solr_search_core"
    echo "Launching browser to search core ..."
    echo "http://$(solr_gethostname):8983/solr/$_core/browse"
    utils_open_url "http://$(solr_gethostname):8983/solr/$_core/browse"
}


function solr_start()
{
    if solr_isRemote ; then
        echo "Cannot start Solr! It is running remotely [$(solr_gethostname)]"
        return
    fi

    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	return
    fi

    if [ $(solr_state) == RUNNING ]; then
        echo "Solr is already running!"
	return
    fi

    echo "Starting Solr..."
    utils_assert_var "DOCSEARCH_SOLR_BIN_DIR" "solr_start"
    (cd "${DOCSEARCH_SOLR_BIN_DIR}" && sh ./solr start -m 1g 2>&1 >/dev/null) 2>&1 >/dev/null &
    sleep 60

    if [ $(solr_state) == RUNNING ]; then
        echo "Solr successfully started."
    else
        echo "solr_start: Failed to start Solr!"
	return
    fi
}


function solr_stop()
{
    if solr_isRemote ; then
        echo "Cannot start Solr! It is running remotely [$(solr_gethostname)]"
        return
    fi

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
    if solr_isRemote ; then
        echo "Cannot re-start Solr! It is running remotely [$(solr_gethostname)]"
        return
    fi

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
    rm -fr "$_core_dir/data" && echo "Successfully deleted index for core \"$_core\""
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
    java -Durl="http://$(solr_gethostname):8983/solr/$_core/update" -jar "$DOCSEARCH_SOLR_DIR/demo/post.jar" "$DOCSEARCH_SOLR_DIR/demo/add.xml"
}


function solr_logs()
{
    local _f
    for _f in "${DOCSEARCH_SOLR_LOGS[@]}"
    do
        echo $_f
    done
}


function solr_kill()
{
    fuser -k $DOCSEARCH_SOLR_PORT/tcp
}


function solr_info_page()
{
    echo "Launching Solr info page ..."

    utils_open_url file://$DOCSEARCH_SOLR_DIR/index.html
}
