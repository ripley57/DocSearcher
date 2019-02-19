# Description:
#   Returns the full path of the calling/sourcing script.
function utils_script_dir()
{
    local _bash_source=$1

    if [ -z "$_bash_source" ]; then
        echo "This script must be run using the Bash shell!"
	return
    fi

    local _script_calling_dir="$(cd "$(dirname "$0")"; pwd -P)"
    #echo "_script_calling_dir=$_script_calling_dir"

    local _script_rel_path="${_bash_source#./}"
    #echo "_script_rel_path=$_script_rel_path"

    local _script_full_path="$_script_calling_dir/$_script_rel_path"
    #echo "_script_full_path=$_script_full_path"

    local _script_dir="$(dirname "$_script_full_path")"
    #echo "_script_dir=$_script_dir"

    echo $_script_dir
}


function utils_check_shell()
{
    if [[ ! "$(readlink -f $(which sh))" =~ "bash" ]]; then
        echo "ERROR: /bin/sh must point to Bash!"
        if [ -f "/etc/debian_version" ]; then
	    # System is probably using dash instead of bash.
	    # dash was introduced for performance, see:
            # https://wiki.ubuntu.com/DashAsBinSh
            echo
	    echo "You are probably using dash. To change this,"
	    echo "use \"sudo dpkg-reconfigure dash\"          "
	    echo
	    echo "Exiting..."
	    exit 1
        fi
    fi
}


function utils_assert_dir()
{
    local _dir=$1
    local _func=$2 

    if [ ! -d "$_dir" ]; then
        echo "utils_assert_dir: $_func: ERROR: No such directory ($_dir)" 
	echo "Exiting..."
	exit 1
    fi
}


function utils_assert_var()
{
    local _name=$1
    local _value=$2
    local _func=$3

    if [ -z "$_value" ]; then
        echo "utils_assert_var: $_func: ERROR: Variable not defined ($_name)"
        echo "Exiting..."
        exit 1
    fi
}


function utils_assert_arg()
{
    local _name=$1
    local _value=$2
    local _func=$3

    if [ -z "$_value" ]; then
         echo "utils_assert_arg: $_func: ERROR: Missing argument ($_name)"
         echo "Exiting..."
	 exit 1
    fi
}


function utils_open_url()
{
     /usr/bin/firefox -new-tab "$1" 2>/dev/null &
}


function utils_press_any_key()
{
    local _tmp
    echo -n "Press any key to continue: "
    read _tmp
}


function utils_is_number()
{
    [[ "$1" =~ [0-9]+ ]]
}


function utils_install_zip()
{
    local _zip=$1
    local _extract_to_dir=$2
    local _extracted_dir=$3

    utils_assert_arg "zip" "$_zip" "utils_download_and_install_zip"
    utils_assert_arg "extract_to_dir" "$_extract_to_dir" "utils_download_and_install_zip"
    utils_assert_arg "extracted_dir" "$_extracted_dir" "utils_download_and_install_zip"

    if [ ! -d "$_extracted_dir" ]; then
        local _cmd="unzip -q \"$_zip\" -d \"$_extract_to_dir\""
	echo "$_cmd"
	eval "$_cmd"
	if [ -d "$_extracted_dir" ]; then
            echo "Unzip success"
        else
            echo "Unzip failed"
        fi
    fi
}

function utils_download_and_install_zip()
{
    local _zip=$1
    local _download_to_dir=$2
    local _download_to_filename=$3
    local _extract_to_dir=$4
    local _extracted_dir=$5

    utils_assert_arg "zip" "$_zip" "utils_download_and_install_zip"
    utils_assert_arg "download_to_dir" "$_download_to_dir" "utils_download_and_install_zip"
    utils_assert_arg "download_to_filename" "$_download_to_filename" "utils_download_and_install_zip"
    utils_assert_arg "extract_to_dir" "$_extract_to_dir" "utils_download_and_install_zip"
    utils_assert_arg "extracted_dir" "$_extracted_dir" "utils_download_and_install_zip"

    # Download the zip to specified temporary directorty.
    # https://www.thegeekstuff.com/2009/09/the-ultimate-wget-download-guide-with-15-awesome-examples/
    if [ ! -f "$_download_to_dir/$_download_to_filename" ]; then
        mkdir -p "$_download_to_dir"
        local _cmd="wget --no-check-certificate -O \"$_download_to_dir/$_download_to_filename\" \"$_zip\""
        echo "$_cmd"
	eval "$_cmd"
	if [ -f "$_download_to_dir/$_download_to_filename" ]; then
            echo "Download success"
        else
            echo "Download failed"
	fi
    fi

    # Extract the zip.
    if [ ! -d "$_extracted_dir" ]; then
        local _cmd="unzip -q \"$_download_to_dir/$_download_to_filename\" -d \"$_extract_to_dir\""
	echo "$_cmd"
	eval "$_cmd"
	if [ -d "$_extracted_dir" ]; then
            echo "Unzip success"
        else
            echo "Unzip failed"
        fi
    fi
}


function utils_get_datestamp()
{
    # YYYY-MM-DD_epochseconds
    date +"%F_%s"
}


function utils_are_you_sure()
{
    echo -n "$1"
    local _tmp
    read _tmp
    [[ "$_tmp" =~ [yY] ]]
}


function utils_get_persisted_value()
{
    local _values_file=$1
    local _name=$2

    utils_assert_var "_values_file" "$_values_file" "utils_get_persisted_value"
    utils_assert_var "_name" "$_name" "utils_get_persisted_value"

    local _value=undefined
    if grep -q "^$_name=" "$_values_file" 2>/dev/null; then
        _value=$(sed -n "s/^$_name=\(.*\)/\1/p" "$_values_file")
    fi
    echo "$_value"
}


function utils_set_persisted_value()
{
    local _values_file=$1
    local _name=$2
    local _value=$3

    utils_assert_var "_values_file" "$_values_file" "utils_set_persisted_value"
    utils_assert_var "_name" "$_name" "utils_set_persisted_value"
    utils_assert_var "_value" "$_value" "utils_set_persisted_value"

    if grep -q "^$_name=" "$_values_file" 2>/dev/null; then
        sed -i "s/$_name=.*/$_name=$_value/" "$_values_file"
    else
        echo "$_name=$_value" >> "$_values_file"
    fi
}


function utils_service_state()
{
    local _host=$1
    local _port=$2

    utils_assert_var "_host" "$_host" "utils_service_state"
    utils_assert_var "_port" "$_port" "utils_service_state"

    local _ret=STOPPED
    if [ "$_host" = "localhost" ]; then
        # Use netstat to check a local service.
        netstat -an | grep -i "listen" | grep :$_port >/dev/null && _ret=RUNNING
    else
        # Use nc to check a remote service.
        nc -w 10 -v "$_host" "$_port" </dev/null 2>/dev/null && _ret=RUNNING
    fi
    echo $_ret
}

function utils_install_netstat()
{
    echo "(CentOS): yum install net-tools"
}
function utils_install_unzip()
{
    echo "(CentOS): yum install unzip"
}
function utils_install_which()
{
    echo "(CentOS): yum install which"
}
function utils_install_wget()
{
    echo "(CentOS): yum install wget"
}

function utils_install_nc()
{
    echo "(CentOS): yum install nmap-ncat"
}
function utils_check_prereqs()
{
    local _prereq_array
    declare -A _prereq_array=(\
['/usr/bin/netstat']=utils_install_netstat \
['/usr/bin/unzip']=utils_install_unzip \
['/usr/bin/which']=utils_install_which \
['/usr/bin/wget']=utils_install_wget \
['/usr/bin/nc']=utils_install_nc \
)
   local _ret=0 ;# No problems and no missing pre-reqs
   local _file_path=
   for _file_path in ${!_prereq_array[*]}
   do
       if [ ! -e "$_file_path" ]; then
	    local _installation_steps=${_prereq_array["$_file_path"]}
            if [ ! -z "$_installation_steps" ]; then
                echo
	        echo "WARNING: Pre-req not installed: $_file_path"
	        echo "To install:"
	        eval "$_installation_steps"
                _ret=1 
            else
                echo
                echo "WARNING: Don't know how to install pre-req: $_file_path"
                _ret=1
            fi
       fi
    done
    return $_ret
}


function utils_init()
{
    if ! utils_check_prereqs; then
        printf "\n%s\n\n" "Exiting..."
        exit 99
    fi

    if ! utils_check_shell; then
        printf "\n%s\n\n" "Exiting..."
        exit 98
    fi
}
utils_init

