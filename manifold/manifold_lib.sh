function manifold_init()
{
    local _pwd="$(utils_script_dir "$BASH_SOURCE")"
    #echo "manifold_init: _pwd=$_pwd"
    DOCSEARCH_MANIFOLD_VERSION=1.9
    DOCSEARCH_MANIFOLD_PORT=8345
    DOCSEARCH_MANIFOLD_USER_VAR="manifold_user"
    DOCSEARCH_MANIFOLD_DIR="${_pwd}"
    DOCSEARCH_MANIFOLD_BIN_DIR="${_pwd}/apache-manifoldcf-1.9/example"
    DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_URL=http://archive.apache.org/dist/manifoldcf/apache-manifoldcf-1.9/apache-manifoldcf-1.9-bin.zip
    DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_FILENAME=apache-manifoldcf-1.9-bin.zip
    # Store downloads here.
    DOCSEARCH_MANIFOLD_DOWNLOAD_TEMP_DIR="${_pwd}/../temp"
    # Extract the zip to this directory.
    DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACT_TO_DIR=$DOCSEARCH_MANIFOLD_DIR
    # The directory we expect to see after extraction.
    DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACTED_DIR=$DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACT_TO_DIR/apache-manifoldcf-1.9
    # Manifold logs.
    DOCSEARCH_MANIFOLD_LOGS=( $DOCSEARCH_MANIFOLD_BIN_DIR/derby.log $DOCSEARCH_MANIFOLD_BIN_DIR/logs/manifoldcf.log )
    # Stores persisted values.
    DOCSEARCH_MANIFOLD_PERSISTED_VALUES="$DOCSEARCH_MANIFOLD_DIR/.persisted_values"
}


function manifold_version()
{
    echo $DOCSEARCH_MANIFOLD_VERSION
}


function manifold_getport()
{
    echo "$DOCSEARCH_MANIFOLD_PORT"
}


function manifold_get_user_var()
{
    echo "$DOCSEARCH_MANIFOLD_USER_VAR"
}


function manifold_set_user()
{
    manifold_set_persisted_value "$(manifold_get_user_var)" "$1"
}


function manifold_get_user()
{
    manifold_get_persisted_value "$(manifold_get_user_var)"
}


function manifold_is_systemd_configured()
{
    [ -f "/etc/systemd/system/manifold.service" ]
}


function manifold_is_systemd_configured_display()
{
    if manifold_is_systemd_configured ; then
        echo "yes"
    else
        echo "no"
    fi 
}


function manifold_is_sudoers_configured()
{
    # Note: This won't work unless we are root user, due to
    #       access restrictions to /etc/sudoers.d/
    if utils_is_root_user ; then
        [ -f /etc/sudoers.d/docsearcher_manifold ]
    else 
        # We'll rely solely on the systemd config.
        manifold_is_systemd_configured
    fi
}


function manifold_is_sudoers_configured_display()
{
    if manifold_is_sudoers_configured ; then
        echo "yes"
    else
        echo "no"
    fi 
}


function manifold_configure_sudoers()
{
    local _manifold_user=$1

    utils_assert_var "_manifold_user" "$_manifold_user" "manifold_configure_sudoers"

    echo "Configuring sudoers for Manifold..."

    if [ "$(whoami)" != "root" ]; then
        echo "You must be root to run this!"
        return 1
    fi   

    local _sudoers_src="${DOCSEARCH_MANIFOLD_DIR}/.sudoers_manifold"
    local _sudoers_tgt="/etc/sudoers.d/docsearcher_manifold"

    #if [ -f "$_sudoers_tgt" ]; then
    #    echo "Sudoers already configured for Manifold!"
    #    echo "To re-configure, remove file:"
    #    echo "$_sudoers_tgt"
    #    return 0
    #fi

    if [ ! -d /etc/sudoers.d/ ]; then
        echo "Installing sudo ..."
        yum install sudo || return 1
    fi

    # Create a sudoers file in /etc/sudoers.d/ to allow
    # the current user to stop/start Manifold using systemctl.
    cat <<EOI >"$_sudoers_src"

Cmnd_Alias SERVICES_MANIFOLD = /bin/systemctl start manifold, /bin/systemctl stop manifold, /bin/systemctl enable manifold, /bin/systemctl disable manifold, /bin/systemctl status manifold

$_manifold_user ALL=(root) NOPASSWD: SERVICES_MANIFOLD

EOI

    # Install our sudoers file.
    if [ -f "$_sudoers_src" ]; then
        cp "$_sudoers_src" "$_sudoers_tgt" 
        chown root:        "$_sudoers_tgt"
        chmod 0440         "$_sudoers_tgt" 
    fi

    # Ensure correct ownership of Manifold files.
    chown -R $_manifold_user $DOCSEARCH_MANIFOLD_BIN_DIR

    [ -f "$_sudoers_tgt" ]
}


function manifold_set_persisted_value()
{
    utils_set_persisted_value "$DOCSEARCH_MANIFOLD_PERSISTED_VALUES" "$1" "$2"
}


function manifold_get_persisted_value()
{
    utils_get_persisted_value "$DOCSEARCH_MANIFOLD_PERSISTED_VALUES" "$1"
}


function manifold_install()
{
    if manifold_isRemote; then
        echo
        echo "Sorry, Manifold is running remotely [$(manifold_gethostname)]."
        echo "Reset the Manifold hostname to locahost if you want"
        echo "to install Manifold locally!"
        echo
        return
    fi

    if [ "$1" == "reinstall" ]; then
        if ! utils_are_you_sure "Re-install Manifold? (y/n): "; then
            return
        fi
	manifold_stop
        manifold_uninstall
    fi
    echo "Installing Manifold ..."
    utils_download_and_install_zip \
    "$DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_URL" \
    "$DOCSEARCH_MANIFOLD_DOWNLOAD_TEMP_DIR" \
    "$DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_FILENAME" \
    "$DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACT_TO_DIR" \
    "$DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACTED_DIR"
}


function manifold_uninstall()
{
    if [ $(manifold_state) == NOT-INSTALLED ]; then
        echo "Manifold not installed!"
	return
    fi

    echo  "Uninstalling Manifold ..."
    local _datestamp=$(utils_get_datestamp)
    if [ -d "$DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACTED_DIR" ]; then
         mv "$DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACTED_DIR" "${DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACTED_DIR}_${_datestamp}"
	 # Disk space can be a problem, so lets really delete it.
	 rm -fr "${DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACTED_DIR}_${datestamp}"
    fi
}


function manifold_gethostname()
{
    local _hostname=
    _hostname="$(utils_get_persisted_value "$DOCSEARCH_MANIFOLD_PERSISTED_VALUES" "hostname")"
    if [ -z "$_hostname" ] || [ "$_hostname" = "undefined" ]; then
        echo "localhost"
    else
        echo "$_hostname"
    fi
}


function manifold_sethostname()
{
    local _hostname=$1
    utils_assert_var "_hostname" "$_hostname" "manifold_sethostname"
    utils_set_persisted_value "$DOCSEARCH_MANIFOLD_PERSISTED_VALUES" "hostname" "$_hostname"
}


function manifold_isRemote()
{
    [ "$(manifold_gethostname)" != "localhost" ]
}


function manifold_ui()
{
    if [ $(manifold_state) == NOT-INSTALLED ]; then
        echo "Manifold not installed!"
	return
    fi
    echo "Launching Manifold UI ..."
    utils_open_url "http://$(manifold_gethostname):8345/mcf-crawler-ui/"
}


function manifold_start()
{
    if manifold_isRemote ; then
        echo "Cannot start Manifold! It is running remotely [$(manifold_gethostname)]"
        return
    fi

    if [ $(manifold_state) == NOT-INSTALLED ]; then
        echo "Manifold not installed!"
	return
    fi

    if [ $(manifold_state) == RUNNING ]; then
        echo "Manifold already running!"
	return
    fi

    echo "Starting Manifold..."

    if manifold_is_systemd_configured && manifold_is_sudoers_configured; then
        local _cmd="sudo systemctl start manifold"
        echo "$_cmd ..."
        eval "$_cmd"
    else
        (cd "${DOCSEARCH_MANIFOLD_BIN_DIR}" && sh ./start.sh 2>&1 &)
    fi
    
    sleep 60

    if [ $(manifold_state) == RUNNING ]; then
        echo "Manifold successfully started."
    else
        echo "Failed to start Manifold!"
	return
    fi
}


function manifold_stop()
{
    if manifold_isRemote ; then
        echo "Cannot start Manifold! It is running remotely [$(manifold_gethostname)]"
        return
    fi

    if [ $(manifold_state) == NOT-INSTALLED ]; then
        echo "Manifold not installed!"
	return
    fi

    if [ $(manifold_state) == STOPPED ]; then
        echo "Manifold already stopped!"
	return
    fi

    echo "Stopping Manifold..."

    if manifold_is_systemd_configured && manifold_is_sudoers_configured; then
        local _cmd="sudo systemctl stop manifold"
        echo "$_cmd ..."
        eval "$_cmd"
    else
        (cd "${DOCSEARCH_MANIFOLD_BIN_DIR}" && sh ./stop.sh 2>&1 &) 2>&1
    fi

    sleep 30

    if [ $(manifold_state) == STOPPED ]; then
        echo "Manifold successfully stopped."
    else
        echo "Failed to stop Manifold!"
	return
    fi
}


function manifold_state()
{  
    if ! manifold_isRemote ; then
        if [ -z "$DOCSEARCH_MANIFOLD_BIN_DIR" ] || [ ! -e "$DOCSEARCH_MANIFOLD_BIN_DIR" ]; then
            echo "NOT-INSTALLED"
	    return
        fi
    fi
    utils_service_state "$(manifold_gethostname)" "$(manifold_getport)"
}


function manifold_installed_state()
{
    local _ret=NOT-INSTALLED
    utils_assert_var "DOCSEARCH_MANIFOLD_BIN_DIR" "$DOCSEARCH_MANIFOLD_BIN_DIR" "manifold_start"
    [ -e "$DOCSEARCH_MANIFOLD_BIN_DIR" ] && _ret=INSTALLED
    echo $_ret
}


function manifold_funcs()
{
    set | grep '^manifold_'
}


function manifold_logs()
{
    local _f
    for _f in "${DOCSEARCH_MANIFOLD_LOGS[@]}"
    do
        echo $_f
    done
}


function manifold_kill()
{
    fuser -k $DOCSEARCH_MANIFOLD_PORT/tcp
}


function manifold_info_page()
{
   echo "Launching Manifold info page ..."
   utils_open_url file://$DOCSEARCH_MANIFOLD_DIR/index.html
}


function manifold_systemd_install()
{
    local _manifold_user=$1

    utils_assert_var "_manifold_user" "$_manifold_user" "manifold_systemd_install"

    if [ "$(whoami)" != "root" ]; then
        echo "You must be root to run this!"
        return 1
    fi   

    local _script_src="${DOCSEARCH_MANIFOLD_DIR}/manifold.service"
    local _script_tgt=/etc/systemd/system/manifold.service

    if [ ! -d /etc/systemd/system ]; then
        echo "Not a systemd system!"
        return
    fi

    #if [ -f "$_script_tgt" ]; then
    #    echo "Manifold systemd script already installed!"
    #    echo "To re-install, remove the file:"
    #    echo "$_script_tgt"
    #    return
    #fi

    echo "Installing Manifold systemd script..."

    chmod +x "${DOCSEARCH_MANIFOLD_BIN_DIR}/start.sh"
    chmod +x "${DOCSEARCH_MANIFOLD_BIN_DIR}/stop.sh"

    cat <<EOI >"$_script_src"
[Unit]
Description=DocSearcher Manifold service
After=network.target

[Service]
Type=simple
TimeoutStartSec=240
User=$_manifold_user
WorkingDirectory=${DOCSEARCH_MANIFOLD_BIN_DIR}
ExecStart=${DOCSEARCH_MANIFOLD_BIN_DIR}/start.sh
ExecStop=${DOCSEARCH_MANIFOLD_BIN_DIR}/stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOI

    if cp "$_script_src" "$_script_tgt" ; then
        echo
        echo "Successfully installed systemd script for Manifold:"
        echo "$_script_tgt"
        echo
        local _cmd
        _cmd="systemctl daemon-reload"
        echo "$_cmd ..." ; eval "$_cmd"
        _cmd="systemctl enable manifold"
        echo "$_cmd ..." ; eval "$_cmd"
        return 0
    else
        echo
        echo "Unable to configure systemd for Manifold!"
	echo
        echo "To manually configure systemd:"
        echo "cp $_script_src" "$_script_tgt"
        echo "systemctl daemon-reload"
        echo "systemctl enable manifold"
        return 1
    fi
}

manifold_init
