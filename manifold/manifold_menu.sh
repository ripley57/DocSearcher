source ./java/java_lib.sh
source ./utils/utils_lib.sh
source ./manifold/manifold_lib.sh

function show_manifold_menu()
{
    if [ $(solr_state) == NOT-INSTALLED ]; then
        echo "Manifold not installed!"
	utils_press_any_key
	return
    fi

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
	echo "x) Exit menu"
	echo
	echo -n "Select option: "
        read _choice

	case $_choice in
        1) manifold_start; press_any_key;;
	2) manifold_stop; press_any_key;;
	3) manifold_ui; press_any_key;;
	x) return;;
	esac
    done
}
