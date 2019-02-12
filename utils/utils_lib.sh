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


function utils_init()
{
    :
}


function utils_open_url()
{
     /usr/bin/firefox -new-tab "$1" &
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
