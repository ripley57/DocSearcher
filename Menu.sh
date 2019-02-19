source ./manifold/manifold_menu.sh 
source ./solr/solr_menu.sh

function show_docsearcher_menu()
{
    local _choice=
    while [ "$_choice" != "x" ]
    do
        clear
	echo "DOCUMENT SEARCHER"
	echo "================="
	printf "%-14s : %s\n" "Solr state" 	"$(menu_solr_state)"
	printf "%-14s : %s\n" "Manifold state"	"$(menu_manifold_state)"
        echo
	echo "1) Perform a Search"
        echo "2) Manage Solr"
	echo "3) Manage Manifold"
	echo "4) Local Installation"
	echo "x) Exit"
	echo
	echo -n "Select option: "
        read _choice

	case $_choice in
        1) solr_menu_search_core;;
        2) show_solr_menu;;
        3) show_manifold_menu;;
	4) show_installation_menu;;
	x) return;;
	esac
    done
}


function menu_solr_state()
{
    if solr_isRemote; then
        local _hostname="$(solr_gethostname)"
        echo "$(solr_state) (Remote $_hostname:$(solr_getport))"
        return
    fi

    local _state=$(solr_state)
    if [ "$_state" = "RUNNING" ]; then
        echo "$_state:$(solr_getport)"
    else
        echo "$_state"
    fi
}


function menu_manifold_state()
{
    if manifold_isRemote; then
        local _hostname="$(manifold_gethostname)"
        echo "$(manifold_state) (Remote $_hostname:$(manifold_getport))"
        return
    fi

    local _state=$(manifold_state)
    if [ "$_state" = "RUNNING" ]; then
        echo "$_state:$(manifold_getport)"
    else
        echo "$_state"
    fi
}


function show_installation_menu()
{
    local _choice
    while [ "$_choice" != "x" ]
    do
        clear
	echo "LOCAL INSTALLATION"
	echo "=================="
        printf "%-8s : %-13s  %s\n" "Java"     "$(java_installed_state)" "(version: $(java_version))"
	printf "%-8s : %-13s  %s\n" "Solr"     "$(menu_solr_state)"           "(version: $(solr_version))"
	printf "%-8s : %-13s  %s\n" "Manifold" "$(menu_manifold_state)"       "(version: $(manifold_version))"
	echo

	# Bash arrays: https://www.linuxjournal.com/content/bash-arrays
	local _menu_options=()

	# Java
	if [ "$(java_installed_state)" == "INSTALLED" ]; then
            echo "1) Re-install Java"
	    _menu_options[1]="java_install reinstall"
	else
            echo "1) Install Java"
	    _menu_options[1]="java_install"
        fi

	# Solr
	if [ "$(solr_installed_state)" == "INSTALLED" ]; then
            echo "2) Re-install Solr"
	    _menu_options[2]="solr_install reinstall"
	else
            echo "2) Install Solr"
	    _menu_options[2]="solr_install"
	fi

	# Manifold
	if [ "$(manifold_installed_state)" == "INSTALLED" ]; then
            echo "3) Re-install Manifold"
	    _menu_options[3]="manifold_install reinstall"
        else
            echo "3) Install Manifold"
	    _menu_options[3]="manifold_install"
	fi

	echo "x) Exit menu"
	echo
	echo -n "Select option: "
        read _choice
        if [ "$_choice" == "1" ]; then
	    eval "${_menu_options[1]}"
	    utils_press_any_key
	fi
	if [ "$_choice" == "2" ]; then
	    eval "${_menu_options[2]}"
	    utils_press_any_key
        fi
	if [ "$_choice" == "3" ]; then
	     eval "${_menu_options[3]}"
	     utils_press_any_key
        fi
        if [ "$_choice" == "x" ]; then
	     return
        fi
    done
}

show_docsearcher_menu
