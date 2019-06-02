#!/usr/bin/env bash

function get_json_value {
  DATA=$1
  KEY=$2
  REGEX=$(echo '"'${KEY}'"\s*:\s*"\K[^"]+')
  VALUE=$(echo "${DATA}" | grep -m1 -oP $REGEX)
  echo $VALUE
}


function command_exists() {
    command -v "$@" > /dev/null 2>&1
}

function get_public_ip () {

    PUBLIC_IP=$(curl -s http://whatismyip.akamai.com/)
    echo "${PUBLIC_IP}"
}


function get_ip_info () {

     if [ -z ${1+x} ] || [ $1 = "" ]; then
        exit_badly "A valid ip address must be provided. Exiting..."
     fi
     IP_ADDRESS="$1"

    URL="https://ipinfo.io/${IP_ADDRESS}"
    DATA=$(curl -s "${URL}")

    echo "${DATA}"
}


function get_domain_from_ip () {

    IP="${1}"

    DOMAIN=$(dig +short -x "${IP}" | sed 's/\.$//')
    echo "${DOMAIN}"

}

function parse_ip_info () {

#     if [ -z ${1+x} ] || [ $1 = "" ]; then
#            exit_badly "A valid json string must be provided. Exiting..."
#     fi

    IP=$(get_json_value "${DATA}" "ip")
    DOMAIN_NAME=$(get_domain_from_ip "${IP}")
    COUNTRY=$(get_json_value "${DATA}" "country")
    STATE=$(get_json_value "${DATA}" "region")
    CITY=$(get_json_value "${DATA}" "city")
    LAT_LON=$(get_json_value "${DATA}" "loc")
    ORGANIZATION=$(get_json_value "${DATA}" "org")
    POSTAL=$(get_json_value "${DATA}" "postal")

    LOCATION="${CITY}, ${STATE} ${POSTAL} ${COUNTRY}"
    SPACES="    "
    echo "${SPACES}IP:${SPACES}${IP}"
    echo "${SPACES}Domain:${SPACES}${DOMAIN_NAME}"
    echo "${SPACES}Location:${SPACES}${LOCATION}"
    echo "${SPACES}Lat/Long:${SPACES}${LAT_LON}"
    echo "${SPACES}Org:${SPACES}${ORGANIZATION}"
}


function ip_info () {

    IP=$(get_public_ip)
    DATA=$(get_ip_info "${IP}")

    parse_ip_info "${DATA}"
}
function array_to_table () {

    ARRAY=("$@")
    for value in "${ARRAY[@]}"; do
        printf "%-8s\n" "${value}"
    done | column
}


function bytes_to_megabits () {
    BYTES="${1}"
    MEGABITS=$(echo "scale=1;$BYTES * 8 / 1000000" |bc)
    echo "${MEGABITS}"
}

function megabytes_to_bytes () {
    MEGABYTES="${1}"
    BYTES=$(echo "scale=1;$MEGABYTES * 1024 * 1024" |bc)
    BYTES=${BYTES%.*}
    echo "${BYTES}"
}

function bytes_to_kilobytes () {
    BYTES="${1}"
    KILOBYTES=$(echo "scale=2;$BYTES / 1000" |bc)
    echo "${KILOBYTES}"
}



function bytes_to_gigabits () {
    BYTES="${1}"
    MEGABITS=$(bytes_to_megabits "${BYTES}")

    GIGABITS=$(echo "scale=3;$MEGABITS / 1000" |bc)
    echo "${GIGABITS}"
}


function system_info() {


    ## REPLACE WITH
    logicalCpuCount=$([ $(uname) = 'Darwin' ] &&
    sysctl -n hw.logicalcpu_max ||
    lscpu -p | egrep -v '^#' | wc -l)

    physicalCpuCount=$([ $(uname) = 'Darwin' ] &&
    sysctl -n hw.physicalcpu_max ||
    lscpu -p | egrep -v '^#' | sort -u -t, -k 2,4 | wc -l)


    # Basic info
    if [ "$(uname)" = "Linux" ]
    then
        OS_NAME=$(lsb_release -d | sed -e "s/.*Description:\s*//g")

        CPU_NAME=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
        CPU_CORES=$(($(lscpu | awk '/^Socket/{ print $2 }') * $(lscpu | awk '/^Core/{ print $4 }')))
        CPU_THREADS=$(cat /proc/cpuinfo | grep processor | wc -l)
        CPU_FREQ=$(awk -F: ' /cpu MHz/ {freq=$2} END {print freq " MHz"}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
        MEMORY_SIZE=$(free -h | awk 'NR==2 {print $2}')


        KERNEL_NAME=$(uname -s -r -m)

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_NAME="$(sw_vers | awk -F  ":\t" '/ProductName/ {print $2}') $(sw_vers | awk -F  ":\t" '/ProductVersion/ {print $2}') $(sw_vers | awk -F  ":\t" '/BuildVersion/ {print $2}')"
        CPU_NAME=$(sysctl -n machdep.cpu.brand_string | grep -Eo '(.+)[0-9\.]+GHz')

        CPU_CORES=$(sysctl -n hw.physicalcpu)
        CPU_THREADS=$(sysctl -n hw.logicalcpu)
        CPU_FREQ=$(sysctl -n machdep.cpu.brand_string | grep -Eo '([0-9\.]+)GHz')
        MEMORY_SIZE=$(sysctl -n hw.memsize | bytes_to_mb)
        DISK_INFO=$(df -hlH | tr -s ' ' | cut -d" " -f 1,2,3,4 | column -t | sed 's/^/    /')

    else
        # we'll assume FreeBSD, might work on other BSDs too
        OS_NAME=$(lsb_release -d | sed -e "s/.*Description:\s*//g")
        CPU_NAME=$(sysctl -n hw.model)
        CPU_CORES=$(sysctl -n hw.ncpu)
        if [ -f "/var/run/dmesg.boot" ]; then
            CPU_FREQ=$(grep -Eo -- '[0-9.]+-MHz' /var/run/dmesg.boot | tr -- '-' ' ')
        fi


        MEMORY_SIZE=$(sysctl -n hw.physmem | bytes_to_mb)

    fi



    KERNEL_NAME=$(uname -s -r -m)

    if [[ ! "$OSTYPE" == "darwin"* ]]; then

        if command_exists lsblk && [ -n "$(lsblk)" ]; then

            DISK_INFO=$(lsblk --nodeps --noheadings --output NAME,SIZE,ROTA --exclude 1,2,11 | sort | awk '{if ($3 == 0) {$3="SSD"} else {$3="HDD"}; printf("%-3s%8s%5s\n", $1, $2, $3)}')
        elif [ -f "/var/run/dmesg.boot" ]; then

            DISK_INFO=$(awk '/(ad|ada|da|vtblk)[0-9]+: [0-9]+.B/ { print $1, $2/1024, "GiB" }' /var/run/dmesg.boot)
        elif command_exists df; then

            DISK_INFO=$(df -h --output=source,fstype,size,itotal | awk 'NR == 1 || /^\/dev/')
        else
            DISK_INFO="N/A"
        fi

    fi


    if [[ "$OSTYPE" == "darwin"* ]]; then
            if sysctl -n machdep.cpu | grep -q AES; then
              AESNI_SUPPORT="True"
            else
                AESNI_SUPPORT="False"
            fi
      else
          if  cat /proc/crypto | grep -q rfc4106-gcm-aesni; then
            AESNI_SUPPORT="True"
        else
             AESNI_SUPPORT="False"

        fi
     fi



    SPACES="    "

    echo "${SPACES}OS:${SPACES}${OS_NAME} (${KERNEL_NAME})"
    echo "${SPACES}CPU:${SPACES}${CPU_NAME} @ ${CPU_FREQ}"
    echo "${SPACES}CPU Cores:${SPACES}${CPU_CORES} (${CPU_THREADS} threads)"
    echo "${SPACES}Memory:${SPACES}${MEMORY_SIZE}"
    echo "${SPACES}AES-NI:${SPACES}${AESNI_SUPPORT}"
    echo "${SPACES}Disks:${SPACES}${DISK_INFO}"

}


DT_NOW=$(date +'%Y-%m-%d %H:%M:%S %Z')


printf '%s\n' '-------------------------------------------------'

echo "    Vultr Speedtest Benchmark"
echo "    https://github.com/moe-m/vultr-speedtest"

echo "    ${DT_NOW}"
echo
ip_info
echo
echo
system_info
echo
echo "    WARNING: this benchmark will use up to 1600MB of bandwidth"
printf '%s\n' '-------------------------------------------------'
echo "    Speedtest will start in 5 seconds. Press Ctr + C or Ctr + z to exit!"
sleep 5;


SUBDOMAINS=("tor-ca-ping" \
            "nj-us-ping" \
            "il-us-ping" \
            "ga-us-ping" \
            "wa-us-ping" \
            "fl-us-ping" \
            "tx-us-ping" \
            "sjo-ca-us-ping" \
            "lax-ca-us-ping" \
            "fra-de-ping" \
            "ams-nl-ping" \
            "par-fr-ping" \
            "lon-gb-ping" \
            "sgp-ping" \
            "hnd-jp-ping" \
            "syd-au-ping");


LOCATIONS=( "Toronto, Canada" \
            "Newark, NJ" \
            "Chicago, IL" \
            "Atlanta, GA" \
            "Seattle, WA" \
            "Miami, FL" \
            "Dallas, TX" \
            "San Jose, CA" \
            "Los Angeles, CA" \
            "Frankfurt, DE" \
            "Amsterdam, NL" \
            "Paris, FR" \
            "London, UK" \
            "Singapore" \
            "Tokyo, JP" \
            "Sydney, AU");




SIZE="100MB"

LABEL=("Location" "Latency" "Size" "MegaBytes/s" "Megabits/s" )

array_to_table "${LABEL[@]}"
echo

NUM=0
for SUBDOMAIN in "${SUBDOMAINS[@]}"; do


    DOMAIN="${SUBDOMAIN}.vultr.com"
    FILE="vultr.com.100MB.bin"
    URL="https://${DOMAIN}/${FILE}"

    PING_FLOAT=$(ping -i 1 -c 4 ${DOMAIN}| tail -1 | awk -F '/' '{print $5}')
    PING=${PING_FLOAT%.*}

    SPEED=$( wget --timeout=10 \
    --output-document="/dev/null" \
    --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" \
    --header="Accept-Encoding: gzip, deflate" \
    --header="Accept-Language: en-US,en;q=0.9" \
    --header="Cache-Control: no-cache" \
    --header="Connection: keep-alive" \
    --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36" \
    "${URL}" 2>&1  | grep -o '\([0-9.]\+ [KM]B/s\)' )



     MegaBytesSec=$(echo "$SPEED" | grep -o '\([0-9.]\+ [KM]B/s\)' | grep -o '[0-9.]\+')

     BytesSec=$( megabytes_to_bytes "${MegaBytesSec}" )
     MegaBitsSec=$( bytes_to_megabits "${BytesSec}" )


#     GigabitsSec=$(bytes_to_gigabits "${BytesSec}")

#      PING="$(ping -i 10 -c 1 ${DOMAIN} | awk -F 'time=' '{print $2}' | grep -o '[0-9.]\+\ ms')"

#    LOC=$(echo "$(echo "$SUBDOMAIN" | sed 's/.*/\u&/')")
    LOCATION="${LOCATIONS[$NUM]}"
#    GEO="${GEOS[$NUM]}"

    LABEL=("${LOCATION}" "${PING} ms" "${SIZE}" "${MegaBytesSec} MB/s" "${MegaBitsSec} Mb/s")

    array_to_table "${LABEL[@]}"
     NUM=$((NUM+1))

done

echo


