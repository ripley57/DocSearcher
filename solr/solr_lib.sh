function solr_init()
{
    local _pwd="$(utils_script_dir "$BASH_SOURCE")"
    #echo "solr_init: _pwd=$_pwd"
    DOCSEARCH_SOLR_VERSION=7.3.1
    DOCSEARCH_SOLR_PORT=8983
    DOCSEARCH_SOLR_USER_VAR="solr_user"
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


function solr_version()
{
    echo $DOCSEARCH_SOLR_VERSION
}


function solr_getport()
{
    echo "$DOCSEARCH_SOLR_PORT"
}


function solr_get_user_var()
{
    echo "$DOCSEARCH_SOLR_USER_VAR"
}


function solr_set_user()
{
    solr_set_persisted_value "$(solr_get_user_var)" "$1"
}


function solr_get_user()
{
    solr_get_persisted_value "$(solr_get_user_var)"
}


function solr_user_check()
{
    if [ $(id -u) = "0" ]; then
       echo
       echo "WARNING: You are running as the root user. For security,"
       echo "         Solr will not start when run as the root user".
       echo
       utils_press_any_key
    fi
}


function solr_is_sudoers_configured()
{
    [ -f /etc/sudoers.d/docsearcher_solr ]
}


function solr_is_sudoers_configured_display()
{
    if solr_is_sudoers_configured ; then
        echo "yes"
    else
        echo "no"
    fi 
}


function solr_configure_sudoers()
{
    local _solr_user=$1

    utils_assert_var "_solr_user" "$_solr_user" "solr_configure_sudoers"

    echo "Configuring sudoers for Solr..."

    if [ "$(whoami)" != "root" ]; then
        echo "You must be root to run this!"
        return 1
    fi   

    local _sudoers_src="${DOCSEARCH_SOLR_DIR}/.sudoers_solr"
    local _sudoers_tgt="/etc/sudoers.d/docsearcher_solr"

    if [ -f "$_sudoers_tgt" ]; then
        echo "Sudoers already configured for Solr!"
        echo "To re-configure, remove file:"
        echo "$_sudoers_tgt"
        return 0
    fi

    if [ ! -d /etc/sudoers.d/ ]; then
        echo "Installing sudo ..."
        yum install sudo || return 1
    fi

    # Create a sudoers file in /etc/sudoers.d/ to allow
    # the current user to stop/start Solr using systemctl.
    cat <<EOI >"$_sudoers_src"

Cmnd_Alias SERVICES_SOLR = /bin/systemctl start, /bin/systemctl stop, /bin/systemctl enable, /bin/systemctl disable, /bin/systemctl status

$_solr_user ALL=(root) NOPASSWD: SERVICES_SOLR

EOI

    # Install our sudoers file.
    if [ -f "$_sudoers_src" ]; then
        cp "$_sudoers_src" "$_sudoers_tgt" 
        chown root:        "$_sudoers_tgt"
        chmod 0440         "$_sudoers_tgt" 
    fi

    [ -f "$_sudoers_tgt" ]
}


function solr_set_persisted_value()
{
    utils_set_persisted_value "$DOCSEARCH_SOLR_PERSISTED_VALUES" "$1" "$2"
}


function solr_get_persisted_value()
{
    utils_get_persisted_value "$DOCSEARCH_SOLR_PERSISTED_VALUES" "$1"
}


function solr_gethostname()
{
    local _hostname=
    _hostname="$(solr_get_persisted_value "hostname")"
    if [ -z "$_hostname" ] || [ "$_hostname" = "undefined" ]; then
        echo "localhost"
    else
        echo "$_hostname"
    fi
}


function solr_isRemote()
{
    [ "$(solr_gethostname)" != "localhost" ]
}


function solr_sethostname()
{
    local _hostname=$1
    utils_assert_var "_hostname" "$_hostname" "solr_sethostname"
    solr_set_persisted_value "hostname" "$_hostname"
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

    if [ "$(whoami)" = "root" ]; then
        echo
        echo "Sorry, you cannot run this option as root!"
        echo
        echo "Solr must be run as a non-root user."
        echo "To correctly install Solr, you must execute" 
        echo "this option as the user that Solr will run as."
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


function solr_is_systemd_configured()
{
    [ -f "/etc/systemd/system/solr.service" ]
}


function solr_is_systemd_configured_display()
{
    if solr_is_systemd_configured ; then
       echo "yes"
    else
       echo "no"
    fi
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

    if solr_is_systemd_configured && solr_is_sudoers_configured; then
        local _cmd="sudo systemctl start solr"
        echo "$_cmd ..."
        eval "$_cmd"
    else
        (cd "${DOCSEARCH_SOLR_BIN_DIR}" && sh ./solr start -m 1g 2>&1 >/dev/null) 2>&1 >/dev/null &
    fi

    sleep 60

    if [ $(solr_state) == RUNNING ]; then
        echo "Solr successfully started."
    else
        echo "Failed to start Solr!"
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

    if solr_is_systemd_configured && solr_is_sudoers_configured; then
        local _cmd="sudo systemctl stop solr"
        echo "$_cmd ..."
        eval "$_cmd"
    else
        (cd "${DOCSEARCH_SOLR_BIN_DIR}" && sh ./solr stop -all 2>&1 >/dev/null) 2>&1 >/dev/null &
    fi

    sleep 30

    if [ $(solr_state) == STOPPED ]; then
        echo "Solr successfully stopped."
    else
        echo "Failed to stop Solr!"
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

    echo "Restarting Solr..."

    if solr_is_systemd_configured && solr_is_sudoers_configured; then
        solr_stop
        solr_start
    else
        (cd "$DOCSEARCH_SOLR_BIN_DIR" && sh ./solr restart -p $DOCSEARCH_SOLR_PORT -m 1g 2>&1 >/dev/null) 2>&1 >/dev/null &
    fi

    if [ $(solr_state) != RUNNING ]; then
        echo "Failed to restart Solr!"
	return
    fi
}


function solr_state()
{
    if ! solr_isRemote ; then
        if [ -z "$DOCSEARCH_SOLR_BIN_DIR" ] || [ ! -e "$DOCSEARCH_SOLR_BIN_DIR" ]; then
            echo "NOT-INSTALLED"
	    return
        fi
    fi
    utils_service_state "$(solr_gethostname)" "$(solr_getport)"
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


function solr_systemd_install()
{
    if [ "$(whoami)" != "root" ]; then
        echo "You must be root to run this!"
        return 1
    fi   

    local _script_src="${DOCSEARCH_SOLR_DIR}/solr.service"
    local _script_tgt=/etc/systemd/system/solr.service

    if [ ! -d /etc/systemd/system ]; then
        echo "Not a systemd system!"
        return 1
    fi

    if [ -f "$_script_tgt" ]; then
        echo "Systemd script already installed!"
        echo "To re-install, remove the file:"
        echo "$_script_tgt"
        return 0
    fi

    echo "Installing Solr systemd script..."

    cat <<EOI >"$_script_src"
[Unit]
Description=DocSearcher Solr service
After=network.target

[Service]
Type=forking
TimeoutStartSec=360
User=${USER}
ExecStart=${DOCSEARCH_SOLR_BIN_DIR}/solr start -m 1g
ExecStop=${DOCSEARCH_SOLR_BIN_DIR}/solr stop -all
PIDFile=${DOCSEARCH_SOLR_BIN_DIR}/solr-${DOCSEARCH_SOLR_PORT}.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOI
    
    if cp "$_script_src" "$_script_tgt" ; then
        echo
        echo "Successfully installed systemd script for Solr:"
        echo "$_script_tgt"
        echo
        local _cmd
        _cmd="systemctl daemon-reload"
        echo "$_cmd ..." ; eval "$_cmd"
        _cmd="systemctl enable solr"
        echo "$_cmd ..." ; eval "$_cmd"
        return 0
    else
        echo
        echo "Unable to configure systemd for Solr!"
	echo
        echo "to manually configure systemd:"
        echo "cp $_script_src" "$_script_tgt"
        echo "systemctl daemon-reload"
        echo "systemctl enable solr"
        return 1
    fi
}

solr_init
#solr_user_check
