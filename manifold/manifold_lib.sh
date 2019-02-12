function manifold_init()
{
    local _pwd="$(utils_script_dir "$BASH_SOURCE")"
    #echo "manifold_init: _pwd=$_pwd"
    DOCSEARCH_MANIFOLD_VERSION=1.9
    DOCSEARCH_MANIFOLD_PORT=8345
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
}
manifold_init


function manifold_version()
{
    echo $DOCSEARCH_MANIFOLD_VERSION
}


function manifold_install()
{
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
    if [ $(solr_state) == NOT-INSTALLED ]; then
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


function manifold_ui()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Manifold not installed!"
	return
    fi
    echo "Launching Manifold UI ..."
    utils_open_url 'http://localhost:8345/mcf-crawler-ui/'
}


function manifold_start()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Manifold not installed!"
	return
    fi

    if [ $(manifold_state) == RUNNING ]; then
        echo "manifold_start: Already running!"
	return
    fi

    echo "Starting Manifold..."
    utils_assert_var "DOCSEARCH_MANIFOLD_BIN_DIR" "manifold_start"
    (cd "${DOCSEARCH_MANIFOLD_BIN_DIR}" && sh ./start.sh 2>&1 >/dev/null &) 2>&1 >/dev/null &
    sleep 60

    if [ $(manifold_state) == RUNNING ]; then
        echo "Manifold successfully started."
    else
        echo "manifold_start: Failed to start Manifold!"
	return
    fi
}


function manifold_stop()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Manifold not installed!"
	return
    fi

    if [ $(manifold_state) == STOPPED ]; then
        echo "manifold_start: Already stopped!"
	return
    fi

    echo "Stopping Manifold..."
    utils_assert_var "DOCSEARCH_MANIFOLD_BIN_DIR" "manifold_start"
    (cd "${DOCSEARCH_MANIFOLD_BIN_DIR}" && sh ./stop.sh  2>&1 >/dev/null &) 2>&1 >/dev/null
    sleep 30

    if [ $(manifold_state) == STOPPED ]; then
        echo "Manifold successfully stopped."
    else
        echo "manifold_start: Failed to stop Manifold!"
	return
    fi
}


function manifold_state()
{  
    if [ -z "$DOCSEARCH_MANIFOLD_BIN_DIR" ] || [ ! -e "$DOCSEARCH_MANIFOLD_BIN_DIR" ]; then
        echo "NOT-INSTALLED"
	return
    fi
    local _ret=STOPPED
    netstat -an | grep -i "listen"| grep :8345 >/dev/null && _ret=RUNNING
    echo $_ret
}


function manifold_installed_state()
{
    local _ret=NOT-INSTALLED
    utils_assert_var "DOCSEARCH_MANIFOLD_BIN_DIR" "manifold_start"
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
