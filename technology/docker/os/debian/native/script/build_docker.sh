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

os_distribution="Debian"
os_version=("11" "bullseye")

database_engine="undefined"
webserver_engine="undefined"

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

ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
ADMIN_EMAIL="admin@localhost"

WEB_PROTOCOL="http"
HTTP_PORT[0]="80" # http number Port
HTTP_PORT[1]="tcp" # http protocol type
ENABLE_GZIP="false"
CERT_FILE=""
KEY_FILE=""

docker_DAEMON_FOREGROUND_EXECUTION_COMMAND='cd /usr/share/docker && /usr/share/docker/bin/docker server --pidfile=/var/run/docker.pid --config=/etc/docker/docker.ini --packaging=deb cfg:default.paths.provisioning=/etc/docker/provisioning cfg:default.paths.data=/var/lib/docker cfg:default.paths.logs=/var/log/docker cfg:default.paths.plugins=/var/lib/docker/plugins'

BUILD_PATH="/usr/local/src"
WORKDIR="/var/www/"
PERSISTENCE_VOLUMES=("/etc/docker/" "/var/log/")
EXPOSE_PORTS="${HTTP_PORT[0]}/${HTTP_PORT[1]}}"
# end set variables
# ============================================================ #
# start definition functions
# ============================== #
# start complement functions

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

function messenger_a() {
    line_divisor="###########################################################################################"
    echo "${line_divisor}"
    echo "########## $* "
    echo "${line_divisor}"
}

function messenger_b() {
    line_divisor="==================================================================================="
    echo "${line_divisor}"
    echo "######## $*"
    echo "${line_divisor}"
}

function messenger_c() {
    line_divisor="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "${line_divisor}"
    echo "###### $*"
    echo "${line_divisor}"
}

function messenger_d() {
    line_divisor="-------------------------------------------------------------------"
    echo "${line_divisor}"
    echo "#### $*"
    echo "${line_divisor}"
}

function messenger_e() {
    line_divisor="..........................................................."
    echo "${line_divisor}"
    echo "## $*"
    echo "${line_divisor}"
}

# end complement functions
# ============================== #
# start main functions
##########################################################

function pre_install_server () {
    messenger_b "Pre install server step"

    function install_generic_tools() {
        messenger_c "Install Generic Tools"

        # update repository
        apt update

        #### start generic tools
        # install basic network tools
        apt install -y iputils-ping net-tools iproute2 traceroute mtr
        # install advanced network tools
        apt install -y tcpdump nmap netcat
        # install DNS tools
        apt install -y dnsutils
        # install process inspector
        apt install -y procps htop psmisc
        # install text editors
        apt install -y nano vim
        # install web-content downloader tools
        apt install -y wget curl
        # install uncompression tools
        apt install -y unzip tar
        # install file explorer with CLI
        apt install -y mc
        # install task scheduler
        apt install -y cron
        # install log register
        apt install -y rsyslog
        #### stop generic tools
    }

    install_generic_tools
}

##########################################################
## install steps

function install_docker () {
    # installing docker
    messenger_c "Installing docker"

    function install_dependencies () {
        # install dependencies from project
        messenger_d "Installing Dependencies"
        apt install -y apt-transport-https software-properties-common wget
        apt install -y gpg
    }

    function install_from_source () {
        # Installing from Source
        messenger_d "Installing from Source"
        echo "this step is not configured"       
    }

    function install_from_apt () {
        # Installing from APT
        messenger_d " Installing from APT"
        
        messenger_e "Setting docker repository"
        mkdir -p /etc/apt/keyrings/
        wget -q -O - https://apt.docker.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/docker.gpg > /dev/null 
        echo "deb [signed-by=/etc/apt/keyrings/docker.gpg] https://apt.docker.com stable main" | tee -a /etc/apt/sources.list.d/docker.list
        apt update
        
        messenger_e "Installing docker"
        apt install -y docker
    }

    function install_complements () {
        messenger_d " Installing Complements"
        #apt install -y ...
    }

    install_dependencies

    ## Installing docker From Source ##
    #install_from_source

    ## Installing docker From APT (Debian package manager) ##
    install_from_apt

    #install_complements;

}

function install_supervisor () {
    # installing supervisor
    messenger_c "Installing supervisor"

    function install_dependencies () {
        # install dependencies from project
        messenger_d "Installing Dependencies"
        echo "this step is not configured"
        #apt install -y ...
    }

    function install_from_source () {
        # Installing from Source
        messenger_d "Installing from Source"
        echo "this step is not configured"
    }

    function install_from_apt () {
        # Installing from APT
        messenger_d " Installing from APT"
        apt install -y supervisor
    }

    function install_complements () {
        messenger_d " Installing Complements"
        echo "this step is not configured"
        #apt install -y ...
    }

    #install_dependencies

    ## Installing supervisor From Source ##
    #install_from_source

    ## Installing supervisor From APT (Debian package manager) ##
    install_from_apt

    #install_complements;

}

#############################

function install_server () {
    messenger_b "Install server step"

    ##  docker
    install_docker
    ##  supervisor
    install_supervisor
}

##########################################################
## start/stop steps ##

function start_docker () {
    # starting docker
    messenger_c "Starting docker"

    #service docker start
    #systemctl start docker
    /etc/init.d/docker start    

    # Daemon running on foreground mode
    #docker -f
}

function stop_docker () {
    # stopping docker
    messenger_c "Stopping docker"

    #service docker stop
    #systemctl stop docker
    /etc/init.d/docker stop

    # ensuring it will be stopped
    # for Daemon running on foreground mode
    killall docker
}

function enable_docker () {
    # Enabling docker
    messenger_c "Enabling docker"

    systemctl enable docker
}

function disable_docker () {
    # Disabling docker
    messenger_c "Disabling docker"

    systemctl disable docker
}

##############

function start_supervisor () {
    # starting supervisor
    messenger_c "Starting supervisor"

    #service supervisor start
    #systemctl start supervisor
    /etc/init.d/supervisor start

    # Daemon running on foreground mode
    #/usr/bin/python3 /usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
}

function stop_supervisor () {
    # stopping supervisor
    messenger_c "Stopping supervisor"

    #service supervisor stop
    #systemctl stop supervisor
    /etc/init.d/supervisor stop

    # ensuring it will be stopped
    # for Daemon running on foreground mode
    killall supervisor
}

function enable_supervisor () {
    # Enabling supervisor
    messenger_c "Enabling supervisor"

    systemctl enable supervisor
}

function disable_supervisor () {
    # Disabling supervisor
    messenger_c "Disabling supervisor"

    systemctl disable supervisor
}

#############################

function start_server () {
    messenger_b "Starting server step"
    # Starting Service

    # starting docker
    start_docker
    start_supervisor
}

function stop_server () {
    messenger_b "Stopping server step"

    # stopping server
    stop_docker
    stop_supervisor
}

function enable_server () {
    messenger_b "Enable server step"

    # enabling server
    enable_docker
    enable_supervisor
}

function disable_server () {
    messenger_b "Disabling server step"

    # stopping server
    disable_docker
    disable_supervisor
}

##########################################################
## configuration steps ##

function configure_docker() {
    # Configuring docker
    messenger_c "Configuring docker"

    local docker_admin_user="${ADMIN_USER:-admin}"
    local docker_admin_password="${ADMIN_PASSWORD:-admin}"
    local docker_admin_email="${ADMIN_EMAIL:-admin@localhost}"
    local docker_protocol="${WEB_PROTOCOL:-http}"
    local docker_http_port="${HTTP_PORT[0]:-3000}"
    local docker_domain=${FQDN}
    local docker_enable_gzip=${ENABLE_GZIP:-false}
    local docker_cert_file="${CERT_FILE}"
    local docker_cert_key="${CERT_KEY}"


    local date_info="$(date +"Y%Ym%md%d-H%HM%MS%S")"
    local config_file="/etc/docker/docker.ini"
    local backup_file="${config_file}.bkp-${date_info}"
    messenger_e "making backup file ${backup_file}"
    cp ${config_file} ${backup_file}


    function configure_docker_security() {
        # Configuring docker Security
        messenger_d "Configuring docker Security"

        messenger_e "Setting Access of docker"
        # Setting Access of docker
        sed -i "s|^;\?admin_user =.*|admin_user = ${docker_admin_user}|" ${config_file}
        sed -i "s|^;\?admin_password =.*|admin_password = ${docker_admin_password}|" ${config_file}
        sed -i "s|^;\?admin_email =.*|admin_email = ${docker_admin_email}|" ${config_file}

    }

    function configure_docker_configs() {
        # Configuring docker
        messenger_d "Configuring docker configs"

        sed -i "s|^;\?protocol =.*|protocol = ${docker_protocol}|" ${config_file}
        sed -i "s|^;\?http_port =.*|http_port = ${docker_http_port}|" ${config_file}
        sed -i "s|^;\?domain =.*|domain = ${docker_domain}|" ${config_file}
        sed -i "s|^;\?enable_gzip =.*|enable_gzip = ${docker_enable_gzip}|" ${config_file}

        if [ "${WEB_PROTOCOL}" = "https" ]; then
            echo "# Setting SSL: Configuring..."
            if [ -n "${CERT_FILE}" ] && [ -n "${CERT_KEY}" ] ; then
                echo "# Files specifieds"
                sed -i "s|^;\?cert_file =.*|cert_file = ${docker_cert_file}|" ${config_file}
                sed -i "s|^;\?cert_key =.*|cert_key = ${docker_cert_key}|" ${config_file}
            else
                echo "# ERROR: Files not specified"
                exit 1
            fi
        else
            echo "# Setting SSL: skipping..."
        fi

    }

    # configuring security on docker
    configure_docker_security

    # setting docker site
    configure_docker_configs
}

function configure_supervisor() {
    # Configuring supervisor
    messenger_c "Configuring Supervisor"

    local supervisor_program_managed_name="docker"
    local supervisor_program_managed_execution_command="${docker_DAEMON_FOREGROUND_EXECUTION_COMMAND}"
    local supervisor_config_path="/etc/supervisor/conf.d/"
    local supervisor_config_file="${supervisor_config_path}${supervisor_program_managed_name}.conf"

    echo "
    [program:${supervisor_program_managed_name}]
    command=bash -c '"${supervisor_program_managed_execution_command}"'
    autostart=true  
    autorestart=true
    startsecs=2
    startretries=10
    stderr_logfile=/var/log/supervisor/%(program_name)s.stderr.log
    stdout_logfile=/var/log/supervisor/%(program_name)s.stdout.log
    redirect_stderr=true
    redirect_stdout=true
    " > ${supervisor_config_file}

    remove_space_from_beginning_of_line "4" "${supervisor_config_file}"
}

#############################

function configure_server () {
    # configure server
    messenger_b "Configure server"

    # configure docker
    configure_docker

    # configure supervisor
    configure_supervisor
}

##########################################################
## check steps ##

function check_configs_docker() {
    # Check config of docker
    messenger_c "Check config of docker"
    echo "# docker not support config test command"

    #dockerctl configtest
}

function check_configs_supervisor() {
    # Check config of supervisor
    messenger_c "Check config of supervisor"
    echo "# supervisor not support config test command"
    #supervisor configtest
}

#############################

function check_configs () {
    messenger_b "Check Configs server"

    # check if the configuration file is ok.
    check_configs_docker
    check_configs_supervisor

}

##########################################################
## test steps ##

function test_docker () {
    # Testing docker
    messenger_c "Testing of docker"


    # is running ????
    #service docker status
    #systemctl status --no-pager -l docker
    /etc/init.d/docker status
    ps -ef --forest | grep docker

    # is listening ?
    ss -pultan | grep :${HTTP_PORT[0]}

    # is creating logs ????
    tail /var/log/docker/*

    # Validating...

    ## scanning docker ports using NETCAT
    nc -zv localhost ${HTTP_PORT[0]}
    #root@docker:~# nc -zv localhost 80
    #Connection to localhost (::1) 80 port [tcp/http] succeeded!

    ## scanning docker ports using NMAP
    nmap -A localhost -sT -p ${HTTP_PORT[0]}
    #root@docker:~# nmap -A localhost -sT -p 80
    #Starting Nmap 7.80 ( https://nmap.org ) at 2024-01-04 05:54 UTC
    #Nmap scan report for localhost (127.0.0.1)
    #Host is up (0.000091s latency).
    #Other addresses for localhost (not scanned): ::1
    #
    #PORT   STATE SERVICE VERSION
    #80/tcp open  http    docker httpd 2.4.56 ((Debian))
    #|_http-server-header: docker/2.4.56 (Debian)
    #| http-title: docker &rsaquo; Setup Configuration File
    #|_Requested resource was http://localhost/wp-admin/setup-config.php
    #Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
    #Device type: general purpose
    #Running: Linux 2.6.X
    #OS CPE: cpe:/o:linux:linux_kernel:2.6.32
    #OS details: Linux 2.6.32
    #Network Distance: 0 hops
    #
    #OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
    #Nmap done: 1 IP address (1 host up) scanned in 8.56 seconds

    # specific tool of commands to test
    curl --head http://localhost:${HTTP_PORT[0]}
    #root@docker:~# curl --head http://localhost:${HTTP_PORT[0]}
    #HTTP/1.1 302 Found
    #Cache-Control: no-store
    #Content-Type: text/html; charset=utf-8
    #Location: /login
    #X-Content-Type-Options: nosniff
    #X-Frame-Options: deny
    #X-Xss-Protection: 1; mode=block
    #Date: Sat, 20 Jan 2024 22:41:14 GMT

}

function test_supervisor () {
    # Testing supervisor
    messenger_c "Testing of supervisor"


    # is running ????
    #service supervisor status
    #systemctl status  --no-pager -l supervisor
    /etc/init.d/supervisor status
    ps -ef --forest | grep supervisor

    # is listening ?
    ss -pultan | grep :${port_supervisor[0]}

    # is creating logs ????
    tail /var/log/supervisor/*

    # Validating...

    # specific tool of commands to test
    supervisorctl status
}


#############################

function test_server () {
    messenger_b "Testing server"

    # testing docker
    test_docker

    # testing supervisor
    test_supervisor
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
messenger_a "Starting docker installation script"
pre_install_server;
install_server;
stop_server;
disable_server;
configure_server;
check_configs;
##start_server;
start_supervisor;
##enable_server;
enable_supervisor;
test_server;
messenger_a "Finished docker installation script"


