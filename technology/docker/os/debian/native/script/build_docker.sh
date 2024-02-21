#!/usr/bin/env bash

# ============================================================ #
# Tool Created date: 15 fev 2024                               #
# Tool Created by: Henrique Silva (rick.0x00@gmail.com)        #
# Tool Name: docker Install                                    #
# Description: My simple script to provision docker Server     #
# License: software = MIT License                              #
# Remote repository 1: https://github.com/rick0x00/srv_container #
# Remote repository 2: https://gitlab.com/rick0x00/srv_container #
# ============================================================ #
# base content:
#   https://docs.docker.com/engine/install/debian/

# ============================================================ #
# start root user checking
if [ $(id -u) -ne 0 ]; then
    echo "Please use root user to run the script."
    exit 1
fi
# end root user checking
# ============================================================ #
# start set variables

## variables above are automatically defined on end of function "check_os_system"
#OS_DISTRIBUTION="Debian"
#OS_VERSION=("11" "bullseye")

## set host.domain.tld used on this application(if not defined is automaticaly used default values(hostname.arpha.local)). exemple:
#HOSTNAME="docker"
#DOMAIN="rick0x00"
#GTLD="com"
#CCTLD="br"
#TLD="com.br"
#FULL_DOMAIN="rick0x00.com.br"
#FQDN="rick0x00.com.br"

HOSTNAME=${HOSTNAME:-$(hostname)}
DOMAIN=${DOMAIN:-"arpha"}
TLD=${TLD:-"${GTLD}${CCTLD:+.}${CCTLD}"}
TLD=${TLD:-"local"}
FULL_DOMAIN=${FULL_DOMAIN:-"${DOMAIN:+${DOMAIN}${TLD:+.}}${TLD}"}
FQDN=${FQDN:-"${HOSTNAME}.${FULL_DOMAIN}"}

## set default admin credential
#ADMIN_USER="sysadmin"
#ADMIN_PASSWORD="strongpassword"
#ADMIN_EMAIL="sysadmin@${FULL_DOMAIN}"

## set DATABASE engine used on this application
#DATABASE_ENGINE="undefined"
## set webserver engine used on this application
#WEBSERVER_ENGINE="undefined"

### WEBSERVER vars
## set basic specifications about web application
#WEB_PROTOCOL="http"
#WEB_HTTP_PORT[0]="80" # http number Port
#WEB_HTTP_PORT[1]="tcp" # http protocol type
#WEB_HTTPS_PORT[0]="443" # https number Port
#WEB_HTTPS_PORT[1]="tcp" # https protocol type
#WEB_ENABLE_TLS="false"
#WEB_CERT_FILE="/etc/letsencrypt/live/${FULL_DOMAIN}/cert.pem"
#WEB_KEY_FILE="/etc/letsencrypt/live/${FULL_DOMAIN}/key.pem"

### DATABASE vars
## set basic specifications about database application
#DATABASE_BIND_ADDRESS="127.0.0.1" # setting to listen only localhost
##DATABASE_BIND_ADDRESS="0.0.0.0" # setting to listen for everybody
#DATABASE_BIND_PORT="3306" # setting to listen on default MySQL port
#
#DATABASE_HOST="${DATABASE_BIND_ADDRESS:-localhost}"
#DATABASE_PORT_NUMBER="${DATABASE_BIND_PORT:-3306}"
#DATABASE_ADMIN_USER="root"
#DATABASE_ADMIN_PASS="strongpassword"
#
#DATABASE_USER="db_user"
#DATABASE_PASS="db_pass"
#DATABASE_USER_ACCESS_HOST="localhost"
#DATABASE_DB_NAME="db_name"
#DATABASE_DB_CHARSET="utf8mb4"
#DATABASE_DB_COLLATE="utf8mb4_unicode_ci"


## set dns server to use on application
DNS_SERVER_ADDRESS_IPv4="8.8.8.8"

## more vars(util for docker instances)
BUILD_PATH="/usr/local/src/"
WORKDIR="/var/lib/docker/"
PERSISTENCE_VOLUMES=("/var/lib/docker/" "/etc/docker/" "/var/log/")
EXPOSE_PORTS="${HTTP_PORT[0]}/${HTTP_PORT[1]} ${HTTPS_PORT[0]}/${HTTPS_PORT[1]}"
# end set variables
# ============================================================ #
# start definition functions
# ============================== #
# start complement functions

function check_os_system(){
    # Function to check OS system
    echo " # ================================== #"
    echo "   Check OS system support"

    # Function to print the operating system version
    print_os_info() {
        echo "    Operating System: $1"
        echo "    Version: $2"
    }

    # List of supported systems and versions(ADD VALIDATED SYSTEMS ABOVE)
    declare -A supported_systems=(
        ["debian"]="11"
        ["ubuntu"]="20 22"
    )

    # Check if the file /etc/os-release exists
    if [ -f /etc/os-release ]; then
        source /etc/os-release

        # Extract ID and detected_version_id from /etc/os-release
        local detected_id=$(grep -oP '(?<=^ID=).*' /etc/os-release | tr -d '"')
        local detected_version_id=$(grep -oP '(?<=^VERSION_ID=).*' /etc/os-release | tr -d '"')

        # Check if the current system is supported
        if [[ -n "${supported_systems[$detected_id]}" && " ${supported_systems[$detected_id]} " =~ " $detected_version_id " ]]; then
            print_os_info "$detected_id" "$detected_version_id"
            echo "    This system is supported."
        else
            print_os_info "$detected_id" "$detected_version_id"
            echo "    This system is not supported."
            exit 1
        fi
    else
        echo "    File /etc/os-release not found."
    fi

    # Exporting OS info if not defined before
    export OS_DISTRIBUTION="${OS_DISTRIBUTION:-$detected_id}"
    export OS_VERSION="${OS_VERSION:-$detected_version_id}"
    echo " # ================================== #"
}

function remove_space_from_beginning_of_line {
    #correct execution
    #remove_space_from_beginning_of_line "<number of spaces>" "<file to remove spaces>"

    # Remove a white apace from beginning of line
    #sed -i 's/^[[:space:]]\+//' "$1"
    #sed -i 's/^[[:blank:]]\+//' "$1"
    #sed -i 's/^ \+//' "$1"

    # check if 2 arguments exist
    if [ $# -eq 2 ]; then
        #echo "correct quantity of args"
        local spaces="${1}"
        local file="${2}"
    else
        #echo "incorrect quantity of args"
        local spaces="4"
        local file="${1}"
    fi
    sed -i "s/^[[:space:]]\{${spaces}\}//" "${file}"
}

function messenger() {
    local line_divisor
    local message
    local category

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --msg)
                message="$2"
                shift
                ;;
            --category)
                category="$2"
                shift
                ;;
            *)
                echo "Argumento inválido: $1"
                return 1
                ;;
        esac
        shift
    done

    case "$category" in
        a)
            line_divisor="###########################################################################################"
            before_line_spacer="#####"
            ;;
        b)
            line_divisor="==================================================================================="
            before_line_spacer="####"
            ;;
        c)
            line_divisor="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            before_line_spacer="###"
            ;;
        d)
            line_divisor="-------------------------------------------------------------------"
            before_line_spacer="##"
            ;;
        e)
            line_divisor="..........................................................."
            before_line_spacer="#"
            ;;
        *)
            echo "Categoria inválida: $category"
            return 1
            ;;
    esac

    echo "${line_divisor}"
    echo "${before_line_spacer} $message"
    echo "${line_divisor}"
}

function check_software_is_installed() {
    # check if software are installed
    messenger --category c --msg "check if software are installed"

    # Check if the number of arguments is correct
    if [ $# -eq 0 ]; then
        messenger --category e --msg "Usage: check_software_is_installed <package_name>"
        exit 1
    fi

    local package_name="$*"

    for package_check in ${package_name} ; do
        messenger --category e --msg "checking if ${package_check} are installed..."
        # Check the available package manager and use the appropriate command to check if the package is installed
        if command -v dpkg &> /dev/nul l; then
            # Debian-based system (dpkg)
            if command -v ${package_check} &> /dev/null  ; then
                messenger --category e --msg "<command> command are used."
                messenger --category e --msg "${package_check} is installed."
                return 0;
            elif type ${package_check} &> /dev/null; then
                messenger --category e --msg "<type> command are used."
                messenger --category e --msg "${package_check} is installed."
                return 0;
            else
                messenger --category e --msg "${package_check} is not installed."
                return 1;
            fi
        else
            messenger --category e --msg "Unable to determine the package manager."
            exit 1
        fi
    done

}

function create_backup_file() {
    echo "# creating backup file..."

    # Check if the number of arguments is correct
    if [ $# -eq 0 ]; then
        messenger --category e --msg "Usage: create_backup_file <file>"
        exit 1
    fi

    local config_file_to_backup="$1"

    # Check if the file exists
    if [ -f ${config_file_to_backup} ]; then
        local date_info="$(date +"Y%Ym%md%d-H%HM%MS%S")"
        local backup_file="${config_file_to_backup}.bkp-${date_info}"
        messenger --category e --msg "making backup file ${backup_file}"
        cp ${config_file_to_backup} ${backup_file}
    else
        messenger --category e --msg "backup file not exist. skipping..."
    fi

}

# end complement functions
# ============================== #
# start main functions
##########################################################
## install steps

#############
# pre install server

function pre_install_server () {
    messenger --category b --msg "Pre install server step"

    function install_generic_tools() {
        messenger --category c --msg "Install Generic Tools"

        # update repository
        apt update -qq >> /dev/null

        #### start generic tools
        # install basic network tools
        #apt install -y iputils-ping net-tools iproute2 traceroute mtr
        local generic_tools_packages_name="iputils-ping net-tools iproute2 traceroute mtr"
        # install advanced network tools
        #apt install -y tcpdump nmap netcat
        local generic_tools_packages_name="${generic_tools_packages_name} tcpdump nmap netcat"
        # install DNS tools
        #apt install -y dnsutils
        local generic_tools_packages_name="${generic_tools_packages_name} dnsutils"
        # install process inspector
        #apt install -y procps htop psmisc
        local generic_tools_packages_name="${generic_tools_packages_name} procps htop psmisc"
        # install text editors
        #apt install -y nano vim
        local generic_tools_packages_name="${generic_tools_packages_name} nano vim"
        # install web-content downloader tools
        #apt install -y wget curl
        local generic_tools_packages_name="${generic_tools_packages_name} wget curl"
        # install uncompression tools
        #apt install -y unzip tar
        local generic_tools_packages_name="${generic_tools_packages_name} unzip tar"
        # install file explorer with CLI
        #apt install -y mc
        local generic_tools_packages_name="${generic_tools_packages_name} mc"
        # install task scheduler
        #apt install -y cron
        local generic_tools_packages_name="${generic_tools_packages_name} cron"
        # install log register
        #apt install -y rsyslog
        local generic_tools_packages_name="${generic_tools_packages_name} rsyslog"
        #### stop generic tools

        ## installing packages
        apt install -y ${generic_tools_packages_name}

    }


    install_generic_tools
   
}

#############################
## install packages
function install_docker () {
    # installing docker
    messenger --category c --msg "Installing docker"

    function install_dependencies () {
        # install dependencies from project
        messenger --category d --msg "Installing Dependencies"
        echo "this step is not configured"
        # update repository
        apt update -qq >> /dev/null
        apt install -y curl 
    }

    function install_from_source () {
        # Installing from Source
        messenger --category d --msg "Installing from Source"
        echo "this step is not configured"
        # configure
        # make
        # make install
    }

    function install_from_apt () {
        # Installing from APT
        messenger --category d --msg " Installing from APT"
        echo "this step is not configured"
        #apt install -y ...
    }

    function install_from_ofc_tool() {
        # Installing from Official TOOL
        messenger --category d --msg "Installing from Official tool"
        #echo "this step is not configured"
        curl -fsSL https://get.docker.com | bash        
    }

    function install_from_rick0x00_tool() {
        # Installing from Official TOOL
        messenger --category d --msg "Installing from Official tool"
        #echo "this step is not configured"
        #curl -fsSL https://get.rick0x00.com | bash        
    }

    function install_complements () {
        messenger --category d --msg " Installing Complements"
        echo "this step is not configured"       
        #apt install -y ...
    }

    # check if docker is installed
    check_software_is_installed "docker"
    if [ $? -ne 0 ]; then

        ## installing docker dependencies
        install_dependencies

        ## Installing docker From Source ##
        #install_from_source

        ## Installing docker From APT (Debian package manager) ##
        #install_from_apt

        ## Installing docker from official tool ##
        install_from_ofc_tool

        ## Installing docker from rick0x00 tool ##
        #install_from_rick0x00_tool

        ## Installing docker complements
        #install_complements;
    else
         messenger --category d --msg " Docker is already installed"
    fi 

}

#############################

function install_server () {
    messenger --category b --msg "Install server step"

    ##  docker
    install_docker
}

##########################################################
## start/stop steps ##

function start_docker () {
    # starting docker
    messenger --category c --msg "Starting docker"

    #service docker start
    #systemctl start docker
    /etc/init.d/docker start    

    # Daemon running on foreground mode
    export DOCKER_DAEMON_FOREGROUND_EXECUTION_COMMAND='/usr/bin/dockerd'
    #eval ${DOCKER_DAEMON_FOREGROUND_EXECUTION_COMMAND}
}

function stop_docker () {
    # stopping docker
    messenger --category c --msg "Stopping docker"

    #service docker stop
    #systemctl stop docker
    /etc/init.d/docker stop

    # ensuring it will be stopped
    # for Daemon running on foreground mode
    killall docker
}

function enable_docker () {
    # Enabling docker
    messenger --category c --msg "Enabling docker"

    systemctl enable docker
}

function disable_docker () {
    # Disabling docker
    messenger --category c --msg "Disabling docker"

    systemctl disable docker
}

#############################

function start_server () {
    messenger --category b --msg "Starting server step"
    # Starting Service

    # starting docker
    start_docker
}

function stop_server () {
    messenger --category b --msg "Stopping server step"

    # stopping server
    stop_docker
}

function enable_server () {
    messenger --category b --msg "Enable server step"

    # enabling server
    enable_docker
}

function disable_server () {
    messenger --category b --msg "Disabling server step"

    # stopping server
    disable_docker
}

##########################################################
## configuration steps ##

function configure_docker() {
    # Configuring docker
    messenger --category c --msg "Configuring docker"

    local docker_dns_server_address_ipv4="${DNS_SERVER_ADDRESS_IPv4:-admin}"


    config_file="/etc/docker/daemon.json"

    # setting backup of config
    create_backup_file "${config_file}"

    function configure_docker_security() {
        # Configuring docker Security
        messenger --category d --msg "Configuring docker Security"
        echo "this step is not configured"
    }

    function configure_docker_configs() {
        # Configuring docker
        messenger --category d --msg "Configuring docker configs"
        #echo "this step is not configured"       

        echo "{ \"dns\" : [ \"${docker_dns_server_address_ipv4}\" ] }" > ${config_file}

    }

    # configuring security on docker
    configure_docker_security

    # setting docker site
    configure_docker_configs
}


#############################

function configure_server () {
    # configure server
    messenger --category b --msg "Configure server"

    # configure docker
    configure_docker

}

##########################################################
## check steps ##

function check_configs_docker() {
    # Check config of docker
    messenger --category c --msg "Check config of docker"
    echo "# docker not support config test command"

    #dockerctl configtest
}

#############################

function check_configs () {
    messenger --category b --msg "Check Configs server"

    # check if the configuration file is ok.
    check_configs_docker

}

##########################################################
## test steps ##

function test_docker () {
    # Testing docker
    messenger --category c --msg "Testing of docker"


    # is running ????
    #service docker status
    #systemctl status --no-pager -l docker
    /etc/init.d/docker status
    ps -ef --forest | grep .*docker.* | grep -v "grep"

    # is creating logs ????
    tail /var/log/docker/*

    # Validating... (using specific commands)
    docker version
    docker compose version

}

#############################

function test_server () {
    messenger --category b --msg "Testing server"

    # testing docker
    test_docker
}

##########################################################

# end main functions
# ============================== #

# end definition functions
# ============================================================ #
# start argument reading

# end argument reading
# ============================================================ #
# start main executions of code
check_os_system
messenger --category a --msg "Starting docker installation script"
pre_install_server;
install_server;
stop_server;
disable_server;
configure_server;
check_configs;
start_server;
enable_server;
test_server;
messenger --category a --msg "Finished docker installation script"
