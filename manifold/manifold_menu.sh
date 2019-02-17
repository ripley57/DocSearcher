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
	printf "%s : %s\n" "Manifold state" "$(manifold_menu_state)"
        echo
	echo "1) Start Manifold"
        echo "2) Stop Manifold"
	echo "3) Launch Manifold UI"
	echo "4) Launch info page"
	echo "5) Manifold logs"
	echo "6) Kill Manifold process"
        echo "7) Change Manifold host"
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
	x) return;;
	esac
    done
}


function manifold_menu_state()
{
    if manifold_isRemote; then
        local _hostname="$(solr_gethostname)"
        echo "Unknown (Remote $_hostname)"
    else
        $(manifold_state)
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
