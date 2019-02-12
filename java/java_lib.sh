function java_init()
{
    # Try to auto-configure the Java environment, by
    # looking for an installed Java and then determing
    # the JAVA_HOME value to set.

    local _java_exe=$(which java)
    if [ -z "$_java_exe" ]; then
        echo "java_init: No Java found!"
	echo
	echo "If running on a Debian-based Linux:"
	echo "sudo apt install openjdk-11-jre"
	echo
	echo "Exiting..."
	exit 1
    fi

    # We have found an installed Java.
    # Follow any symlinks to find where the real java exe is.
    local _java_real_exe="$(readlink -f "$(which java)")"

    # Assuming that the real java exe is in a "bin" directory,
    # we now need to determine the parent of that directory.
    # (This will be our JAVA_HOME value.)
    local _java_home="${_java_real_exe%%/bin*}"
    if [ ! -z "$_java_home" ]; then
        #echo "java_init: _java_home=$_java_home"
        export JAVA_HOME="$_java_home"
    else
        echo "java_init: Could not determine JAVA_HOME to set!"
	exit 1
    fi
}
java_init


function java_version()
{
    if [ "$(java_installed_state)" == INSTALLED ]; then
        java -version 2>&1 | head -1 | grep -i java
    else
        echo NOT-INSTALLED
    fi
}


function java_installed_state()
{
    local _ret=NOT-INSTALLED
    [ ! -z "$JAVA_HOME" ] && _ret=INSTALLED
    echo $_ret
}


function java_install()
{
    echo
    echo "Sorry, you'll need to install/re-install"
    echo "Java yourself on Linux, as I don't have"
    echo "any pre-prepared zips to simply extract!"
    echo
    if [ -f /etc/debian_version ]; then
        echo "You appear to be running a Debian-based Linux,"
	echo "so try this to install (OpenJDK) Java:"
        echo "    apt-get update"
        echo "    apt-get install default-jdk"
        echo
        echo "Or if you want to install Oracle JDK:"
        echo "    apt-get update"
        echo "    add-apt-repository ppa:webupd8team/java"
        echo "    apt-get update"
        echo "    apt-get install oracle-java8-installer"
        echo 
        echo "To later choose which installed Java to use"
        echo "(and see where the JAVA_HOME directory is):"
        echo "    update-alternatives --config java"
	echo 
	echo "See:"
	echo "https://thishosting.rocks/install-java-ubuntu/#ubuntu-default"
	echo
    fi
}
