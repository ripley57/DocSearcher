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
	printf "%-12s : %s\n" "Manifold status" "$(manifold_state)"
        echo
	echo "1) Start Manifold"
        echo "2) Stop Manifold"
	echo "3) Launch Manifold UI"
	echo "4) Launch info page"
	echo "5) Manifold logs"
	echo "6) Kill Manifold process"
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
	x) return;;
	esac
    done
}


function manifold_menu_logs()
{
    echo
    manifold_logs
    echo
}


function manifold_menu_ui()
{
    if [ "$(manifold_state)" != "RUNNING" ]; then
        echo "Manifold must be running!"
	utils_press_any_key
	return
    fi
    manifold_ui
}
