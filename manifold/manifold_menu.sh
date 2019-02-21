source ./java/java_lib.sh
source ./utils/utils_lib.sh
source ./manifold/manifold_lib.sh

function show_manifold_menu()
{
    local _choice=
    while [ "$_choice" != "x" ]
    do
        clear
	echo "MANAGE MANIFOLD"
	echo "==============="
	printf "%-18s : %s\n" "Manifold state"     "$(manifold_menu_state)"
        printf "%-18s : %s\n" "Manifold user"      "$(manifold_get_user)"
        printf "%-18s : %s\n" "Systemd configured" "$(manifold_is_systemd_configured_display)"
        if utils_is_root_user ; then
            printf "%-18s : %s\n" "Sudoers configured" "$(manifold_is_sudoers_configured_display)"
        fi
        echo
	echo "1) Start Manifold"
        echo "2) Stop Manifold"
	echo "3) Launch Manifold UI"
	echo "4) Launch info page"
	echo "5) Manifold logs"
	echo "6) Kill Manifold process"
        echo "7) Change Manifold host"
        echo "8) Configure systemd & sudoers"
	echo "x) Exit menu"
	echo
	echo -n "Select option: "
        read _choice

	case $_choice in
        1) manifold_start; 	utils_press_any_key;;
	2) manifold_stop; 	utils_press_any_key;;
	3) manifold_menu_ui;	utils_press_any_key;;
	4) manifold_info_page;	utils_press_any_key;;
	5) manifold_menu_logs; 	utils_press_any_key;;
	6) manifold_kill;	utils_press_any_key;;
        7) manifold_menu_hostname;;
        8) manifold_menu_systemd_install; utils_press_any_key;;
	x) return;;
	esac
    done
}


function manifold_menu_systemd_install()
{
    if ! utils_is_root_user ; then
        echo "You must be root to run this!"
        return 1
    fi   

    echo -n "Enter user Manifold will run as: "
    local _manifold_user=
    read _manifold_user
    if [ -z "$_manifold_user" ]; then
        echo "No user specified, so will do nothing."
        return
    fi
    if manifold_configure_sudoers "$_manifold_user"; then
        manifold_set_user "$_manifold_user"
        manifold_systemd_install "$_manifold_user"
    else
        echo "Sorry, unable to configure systemd and sudoers for Manifold!"
    fi
}


function manifold_menu_state()
{
    if manifold_isRemote; then
        local _hostname="$(solr_gethostname)"
        echo "$(manifold_state) (Remote $_hostname)"
    else
        manifold_state
    fi
}


function manifold_menu_logs()
{
    if manifold_isRemote ; then
        echo
        echo "Sorry, cannot list Manifold logs!"
        echo "Manifold is running remotely [$(manifold_gethostname)]"
        echo
        return
    fi

    echo
    manifold_logs
    echo
}


function manifold_menu_ui()
{
    if ! manifold_isRemote && [ "$(manifold_state)" != "RUNNING" ]; then
        echo "Manifold must be running!"
	utils_press_any_key
	return
    fi
    manifold_ui
}


function manifold_menu_hostname()
{
    local _new_hostname=
    local _current_hostname="$(manifold_gethostname)"
    echo "Current Manifold host: $_current_hostname"
    echo -n "Enter new Manifold host, or x: "
    read _new_hostname
    if [ ! -z "$_new_hostname" ] && [ "$_new_hostname" != "x" ]; then
        manifold_sethostname "$_new_hostname"
    fi
}
