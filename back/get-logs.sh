#!/bin/bash

declare -a CMD=""
declare -a MACHINE=""
declare -a MACHINES=("*")
declare -a PWD="*"

function Usage() {
    echo "Invalid input parameters, Usage:"
    echo "sh $0 -m <MACHINE_IP> <CMD>"
    echo "sh $0 <CMD>"
    echo "sh $0 -l"
    exit 1
}

function parse_param() {
    arg_num=1
    while getopts lm: opt; do
        case $opt in
            l)
                list_machines
            ;;
            m)
                check_param "$OPTARG"
                MACHINE="$OPTARG"
                arg_num=3
            ;;
            \?)
                Usage
            ;;
        esac
    done

    if [ $# -lt $arg_num ];then
        Usage
    fi

    if [ $arg_num -ge 3 ];then
        CMD=${@:3}
    else
        CMD=${@:1}
    fi
}

function check_param() {
    if [ -z "$1" ]; then
        Usage
        exit 1
    fi
}

function list_machines() {
    echo "machines: ${MACHINES[@]}"
    exit 0
}

function auto_smart_ssh() {
    expect -c "set timeout 60;
        spawn ssh -o StrictHostKeyChecking=no $1 ${@:3};
        expect  {
            *assword:*  {send -- $2\r;
                expect {
                    *denied* {exit 2;}
                    *Aborted* {exit 1;}
                    *SUCCESS*DONE* {exit 0;}
                    eof {exit -1;}
                }
            }
            eof {exit 1;}
            timeout {exit 10;}
        }
    "
    return $?
}

source ~/.bash_profile > /dev/null
OLDPWD=`pwd`
parse_param ${@}

echo "cmd === $CMD"
if [ -z "${MACHINE}" ];then
    for mc in ${MACHINES[@]};do
        echo "##########################################################"
        echo "###   ${mc}"
        echo "##########################################################"
        auto_smart_ssh root@${mc} "${PWD}" "${CMD}"
    done
else
    auto_smart_ssh root@${MACHINE} "${PWD}" "${CMD}"
fi

exit 0

