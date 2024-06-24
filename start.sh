#!/bin/bash

ctrl_c() {
	echo "Script interrupted by user."
	exit 1
}

host_installation() {
	cat <<EOF
    wget -O titan.tar.gz https://github.com/Titannet-dao/titan-node/releases/download/v0.1.16/titan_v0.1.16_linux_amd64.tar.gz &&
    tar -xvf titan.tar.gz &&
    cd titan_v0.1.16_linux_amd64 && 
    (nohup ./titan-edge daemon start --init --url https://test-locator.titannet.io:5000/rpc/v0 &>/dev/null &) && 
    sleep 5 && 
    ./titan-edge bind --hash=1F88B74B-CD77-4D8D-8FD1-43DFE41909D4 https://api-test1.container1.titannet.io/api/v2/device/binding
EOF
}

docker_installation() {
	cat <<EOF
  wget -O start.sh https://gist.githubusercontent.com/syahidnurrohim/e8a8bb896efdd670e5151c7e0343f245/raw/f338c2a536dad306b09be8e3f3122fd25e11c12e/gistfile1.txt &&
    bash start.sh "1F88B74B-CD77-4D8D-8FD1-43DFE41909D4" 5 10
EOF
}

docker_restart() {
	cat <<EOF
    docker exec titan1 bash -c "titan-edge bind --hash=1F88B74B-CD77-4D8D-8FD1-43DFE41909D4 https://api-test1.container1.titannet.io/api/v2/device/binding" &&
    docker exec titan2 bash -c "titan-edge bind --hash=1F88B74B-CD77-4D8D-8FD1-43DFE41909D4 https://api-test1.container1.titannet.io/api/v2/device/binding" &&
    docker exec titan3 bash -c "titan-edge bind --hash=1F88B74B-CD77-4D8D-8FD1-43DFE41909D4 https://api-test1.container1.titannet.io/api/v2/device/binding" &&
    docker exec titan4 bash -c "titan-edge bind --hash=1F88B74B-CD77-4D8D-8FD1-43DFE41909D4 https://api-test1.container1.titannet.io/api/v2/device/binding" &&
    docker exec titan5 bash -c "titan-edge bind --hash=1F88B74B-CD77-4D8D-8FD1-43DFE41909D4 https://api-test1.container1.titannet.io/api/v2/device/binding"
EOF
}

# Function to display usage information
usage() {
	echo "Usage: $0 [--ip_file <ip_file>] [--password <password>]"
	exit 1
}

# Trap Ctrl+C and call ctrl_c function
trap ctrl_c INT

ip_file=""
password=""
docker=false
restart=false

# Parse command line options
while [[ $# -gt 0 ]]; do
	case "$1" in
	--ip_file)
		ip_file="$2"
		shift 2
		;;
	--password)
		password="$2"
		shift 2
		;;
	--docker)
		docker=true
		shift 1
		;;
	--restart)
		restart=true
		shift 1
		;;
	*)
		usage
		;;
	esac
done

# Check if required options are provided
if [[ -z $ip_file || -z $password ]]; then
	usage
fi

for i in $(jq -r '.[]' $ip_file); do
	echo "============================="
	echo "Starting $i.."
	echo "============================="
	if [[ $restart == true ]]; then
		if [[ $docker == true ]]; then
			sshpass -p $password ssh -o StrictHostKeyChecking=no root@$i "$(docker_restart)"
		fi
	else
		if [[ $docker == true ]]; then
			sshpass -p $password ssh -o StrictHostKeyChecking=no root@$i "$(docker_installation)"
		else
			sshpass -p $password ssh -o StrictHostKeyChecking=no root@$i "$(host_installation)"
		fi
	fi
done
