#!/bin/bash

ctrl_c() {
	echo "Script interrupted by user."
	exit 1
}

# Trap Ctrl+C and call ctrl_c function
trap ctrl_c INT

function installation() {
	cat <<EOF
    cd titan_v0.1.16_linux_amd64 && 
    (nohup ./titan-edge daemon start --init --url https://test-locator.titannet.io:5000/rpc/v0 &>/dev/null &) && 
    sleep 5 && 
    ./titan-edge bind --hash=1F88B74B-CD77-4D8D-8FD1-43DFE41909D4 https://api-test1.container1.titannet.io/api/v2/device/binding
EOF
}

for i in $(jq -r '.[]' "$1"); do
	echo "Resuming $i.."
	sshpass -p "$2" ssh -o StrictHostKeyChecking=no root@"$i" "$(installation)"
	#sshpass -p "$2" ssh -o StrictHostKeyChecking=no root@"$i" "cd titan_v0.1.16_linux_amd64 && ./titan-edge daemon start --init --url https://test-locator.titannet.io:5000/rpc/v0";
done
