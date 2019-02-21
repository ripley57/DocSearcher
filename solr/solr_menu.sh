source ./java/java_lib.sh
source ./utils/utils_lib.sh
source ./solr/solr_lib.sh

function show_solr_menu()
{
    local _choice=
    while [ "$_choice" != "x" ]
    do
        clear
	echo "MANAGE SOLR"
	echo "==========="
	printf "%-18s : %s\n" "Solr state" 	   "$(menu_solr_state)"
        printf "%-18s : %s\n" "Solr user"          "$(solr_get_user)"
        printf "%-18s : %s\n" "Systemd configured" "$(solr_is_systemd_configured_display)"
        printf "%-18s : %s\n" "Sudoers configured" "$(solr_is_sudoers_configured_display)"
        echo
	echo "1)  Search a core"
        echo "2)  Start Solr"
	echo "3)  Stop Solr"
	echo "4)  Restart Solr"
	echo "5)  List Solr cores"
	echo "6)  Create Solr core"
	echo "7)  Delete Solr core"
	echo "8)  Delete index of Solr core"
	echo "9)  Import sample docs"
	echo "10) Solr logs"
	echo "11) Kill Solr process"
	echo "12) Launch info page"
        echo "13) Change Solr host"
        echo "14) Configure systemd & sudoers"
	echo "x)  Exit menu"
	echo
	echo -n "Select option: "
        read _choice

	case $_choice in
        1)  solr_menu_search_core;;
	2)  solr_menu_start;		utils_press_any_key;;
	3)  solr_menu_stop;		utils_press_any_key;;
	4)  solr_menu_restart;		utils_press_any_key;;
        5)  solr_menu_list_cores;;
        6)  solr_menu_create_core;;
        7)  solr_menu_delete_core;;
	8)  solr_menu_delete_index;;
	9)  solr_menu_import_sample_docs;;
	10) solr_menu_logs; 		utils_press_any_key;;
	11) solr_menu_kill;		utils_press_any_key;;
	12) solr_info_page;		utils_press_any_key;;
        13) solr_menu_hostname;;
        14) solr_menu_systemd_install;	utils_press_any_key;;
	x) return;;
	esac
    done
}


function solr_menu_systemd_install()
{
    if [ "$(whoami)" != "root" ]; then
        echo "You must be root to run this!"
        return 1
    fi   

    echo -n "Enter user Solr will run as: "
    local _solr_user=
    read _solr_user
    if [ -z "$_solr_user" ]; then
        echo "No user specified, so will do nothing."
        return
    fi
    if solr_configure_sudoers "$_solr_user"; then
        solr_set_user "$_solr_user"
        solr_systemd_install
    else
        echo "Sorry, unable to configure systemd and sudoers for Solr!"
    fi
}


function solr_menu_state()
{
    if solr_isRemote; then
        local _hostname="$(solr_gethostname)"
        echo "$(solr_state) (Remote $_hostname)"
    else
        solr_state
    fi
}


function solr_menu_kill()
{
    if solr_isRemote ; then
        echo
        echo "Sorry, can't kill Solr!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        return
    fi

    solr_kill
}


function solr_menu_start()
{
    if solr_isRemote ; then
        echo
        echo "Sorry, can't start Solr!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        return
    fi

    solr_start
}


function solr_menu_stop()
{
    if solr_isRemote ; then
        echo
        echo "Sorry, can't stop Solr!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        return
    fi

    solr_stop
}


function solr_menu_restart()
{
    if solr_isRemote ; then
        echo
        echo "Sorry, can't restart Solr!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        return
    fi

    solr_restart
}


function solr_menu_logs()
{
    if solr_isRemote ; then
        echo
        echo "Sorry, can't list logs!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        return
    fi

    echo
    solr_logs
    echo
}


function solr_menu_hostname()
{
    local _new_hostname=
    local _current_hostname="$(solr_gethostname)"
    echo "Current Solr host: $_current_hostname"
    echo -n "Enter new Solr host, or x: "
    read _new_hostname
    if [ ! -z "$_new_hostname" ] && [ "$_new_hostname" != "x" ]; then
        solr_sethostname "$_new_hostname"
    fi
}


# Returns:
#	Name of selected Solr core.
function solr_select_core()
{
    local __returnvar=$1
    local _title=$2

    local _core_array
    local _choice
    local _cnt
    local _set
    local _c

    # Return selected core using passed variable name.
    eval $__returnvar=""
    eval $(solr_cores)

    while [ "$_choice" != "x" ]
    do
        clear
        echo "$_title"
	echo

        if [ ${#_core_array[*]} -eq 0 ]; then
            echo "No cores found"
	    echo
	    utils_press_any_key
	    return
        fi

        let _cnt=0
        for _c in "${_core_array[@]}"
        do
            let _cnt=_cnt+1
            echo "$_cnt) $_c"
        done
        echo "x) Exit menu"
        echo
        echo -n "Select a number, or x: "
        read _choice

	let _sel=0
	if utils_is_number "$_choice" ; then
	    if [ $_choice -ge 1 ] && [ $_choice -le $_cnt ]; then
                let _sel=$_choice-1
	        _core="${_core_array[$_sel]}"
	        #echo "You selected: $_core"
    		# Return selected core using passed variable name.
    		eval $__returnvar="$_core"
		_choice=x
            fi
	fi
    done
}


function solr_menu_import_sample_docs()
{
    if solr_isRemote ; then
        echo
        echo "Sorry, can't import sample docs!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        utils_press_any_key
        return
    fi

    if [ "$(solr_state)" != "RUNNING" ]; then
        echo "Solr must be running!"
	utils_press_any_key
	return
    fi

    local _core
    solr_select_core "_core" "Select core to import docs into:
    
(Note: The core must use the \"_default\" configset)"
    if [ ! -z "$_core" ]; then
        [ "$(solr_state)" == "STOPPED" ] && solr_start
        solr_import_sample_docs "$_core"
        utils_press_any_key
    fi
}


function solr_menu_search_core()
{
    # Searching a remote instance of Solr?
    local _core_to_search=
    if solr_isRemote; then
        echo
        echo "NOTE: You are using a remote Solr instance [$(solr_gethostname)]."
        echo 
        echo -n "Please enter name of the core to search, or x: "
        read _core_to_search
        if [ ! -z "$_core_to_search" ] && [ "$_core_to_search" != "x" ]; then
            solr_search_core "$_core_to_search"
            utils_press_any_key
        fi
        return
    fi

    if [ $(solr_state) != "RUNNING" ]; then
        echo "Solr must be running!"
	utils_press_any_key
	return
    fi

    local _core
    solr_select_core "_core" "Select core to search:"
    if [ ! -z "$_core" ]; then
        [ "$(solr_state)" == "STOPPED" ] && solr_start
        solr_search_core "$_core"
        utils_press_any_key
    fi
}


function solr_menu_list_cores()
{
    if solr_isRemote; then
        echo
        echo "Sorry, cannot list cores!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        utils_press_any_key
        return
    fi

    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	utils_press_any_key
	return
    fi

    local _core_array
    local _choice
    local _cnt
    local _sel
    local _core

    eval $(solr_cores)

    while [ "$_choice" != "x" ]
    do
        clear
        echo "Existing Solr cores:"
	echo

        if [ ${#_core_array[*]} -eq 0 ]; then
            echo "No cores found"
	    echo
	    utils_press_any_key
	    return
        fi

        let _cnt=0
        for _c in "${_core_array[@]}"
        do
            let _cnt=_cnt+1
            echo "$_cnt) $_c"
        done
	_choice=x
    done
    echo
    utils_press_any_key
}


function solr_menu_delete_core()
{
    if solr_isRemote; then
        echo
        echo "Sorry, cannot delete a core!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        utils_press_any_key
        return
    fi

    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	utils_press_any_key
	return
    fi

    local _core
    solr_select_core "_core" "Select core to delete:"
    if [ ! -z "$_core" ]; then
	solr_delete_core "$_core"
        utils_press_any_key
    fi
}


function solr_menu_create_core()
{
    if solr_isRemote; then
        echo
        echo "Sorry, cannot create a core!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        utils_press_any_key
        return
    fi

    if [ $(solr_state) != "RUNNING" ]; then
        echo "Solr must be running!"
	utils_press_any_key
	return
    fi

    local _core
    echo
    echo -n "Enter name for a new core, or press return to quit: "
    read _core
    if [ -z "$_core" ]; then
	return
    fi

    local _configset_array
    local _configset
    local _choice
    local _cnt
    local _cs
    while [ "$_choice" != "x" ]
    do
	clear
        echo "Select configset for core \"$_core\":"
	echo
	eval $(solr_configsets)
	let _cnt=0
        for _cs in "${_configset_array[@]}"
	do
            let _cnt=_cnt+1
	    echo "$_cnt) $_cs"
	done
        echo "x) Exit menu"
        echo
        echo -n "Select a number, or x: "
	read _choice
	let _sel=0
	if utils_is_number "$_choice"; then
	    if [ $_choice -ge 1 ] && [ $_choice -le $_cnt ]; then
                let _sel=$_choice-1
	        _configset="${_configset_array[$_sel]}"
	        #echo "You selected: $_configset"
		_choice=x
            fi
	fi
    done

    if [ ! -z "$_core" ] && [ ! -z "$_configset" ]; then
        solr_create_core "$_core" "$_configset"
	utils_press_any_key
    fi
}


function solr_menu_delete_index()
{
    if solr_isRemote; then
        echo
        echo "Sorry, cannot delete a core index!"
        echo "Solr is running remotely [$(solr_gethostname)]"
        echo
        utils_press_any_key
        return
    fi

    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Solr not installed!"
	utils_press_any_key
	return
    fi

    local _core
    solr_select_core "_core" "Select core index to delete:"
    if [ ! -z "$_core" ]; then
	solr_delete_index "$_core"
        utils_press_any_key
    fi
}
