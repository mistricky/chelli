#!/bin/zsh

declare -A OPTIONS
declare -A HELP_OPTION_INFO
declare -A COMMANDS
declare -A OPTION_VALUES
declare -A WAIT_FOR_EXEC_OPTION_ACTIONS

INIT_COMMAND_NAME="main"
WILDCARD_COMMAND_NAME="*"
CURRENT_COMMAND_NAME=$INIT_COMMAND_NAME

CURRENT_WALK_OPTION=()
HELP_COMMAND_INFO=()

version=1.0.0

raise_error() {
    echo $1
    exit 1
}

# error_type error_message
format_error() {
    raise_error "[$1]: $2" 
}

# error_message
parameter_error() {
    format_error "Parameter Error" "${1}"
}

# error_message
option_error() {
    format_error "Option Error" "${1}"
}

# error_message
command_error() {
    format_error "Command Error" "${1}"
}

# has_value short_option long_option description fn specify_command
_option() {
    local specify_command=${6:-"main"}
    local key_name="$specify_command|$3"

    OPTIONS[$key_name]="$2,$3,$5,$1"

    HELP_OPTION_INFO[$key_name]="-$2, --$3   $4"
}

# name description fn
command() {
    COMMANDS[$1]="$3"

    HELP_COMMAND_INFO+=("$1   $2")
}

required_option() {
    _option true $* 
}

option() {
    _option false $*
}

# CLI_name description version
set_metadata() {
    CLI_name=$1
    CLI_description=$2
    CLI_version=${3:-"v1.0.0"}
}

# CLI_usage
set_usage() {
    CLI_usage=$1
}

print_version() {
    echo "$CLI_name version $CLI_version"
    exit
}

# option_name 
_exract_option() {
    for key val in ${(kv)OPTIONS}
    do     
        if [[ $key =~ "^$CURRENT_COMMAND_NAME\|" || $key =~ "^\\$WILDCARD_COMMAND_NAME\|" ]];then
            eval local parsed_val="(${val//,/ })"

            if [[ $1 == "-${parsed_val[1]}" || $1 == "--${parsed_val[2]}" ]];then
                CURRENT_WALK_OPTION=($parsed_val)
                return
            fi
        fi
    done

    if [[ $CURRENT_COMMAND_NAME == $INIT_COMMAND_NAME ]];then
        option_error "Unknown option $1"
    else
        option_error "Unknown option $1 on command $CURRENT_COMMAND_NAME"
    fi
}

# set result of action of the option
apply() {
    OPTION_VALUES[$current_walk_option_name]=$1
}

exec_options() {
    for long_option_name val in ${(kv)WAIT_FOR_EXEC_OPTION_ACTIONS}
    do
        local exec_arr=(${val//|/ })

        current_walk_option_name=$long_option_name

        eval ${exec_arr[0]} ${exec_arr[1]} $CURRENT_COMMAND_NAME
    done

    $COMMANDS[$CURRENT_COMMAND_NAME] $OPTION_VALUES
}

# command_name
print_help() {
    echo 
    echo $CLI_description
    echo 
    echo ${CLI_usage:-"Usage: $CLI_name [options] commands"}
    echo

    for command_name help_option in ${(kv)HELP_OPTION_INFO}
    do
        if [[ $command_name =~ "^$1\|" || $command_name =~ "^\\$WILDCARD_COMMAND_NAME\|" ]];then
            echo $help_option
        fi
    done

    echo 
    exit
}

# build-in options
option "v" "version" "Print version information & quit" print_version
option "h" "help" "Print handbook & quit" print_help "*"

# args
cli_parse() {
    local is_skip=false

    for i ({1..${#*[@]}})
    do  
        if [[ $is_skip == true ]];then
            is_skip=false
            continue
        fi

        local arg=${*[i]}

        if [[ $arg =~ "^(-|--)" ]];then
            _exract_option ${*[i]}

            local fn=${CURRENT_WALK_OPTION[3]}
            local long_option=${CURRENT_WALK_OPTION[2]}

            # is option
            # the option have to accept a value 
            if [[ ${CURRENT_WALK_OPTION[4]} == true ]];then
                is_skip=true
                local value=${*[i+1]}
                
                if [[ $value == "" ]];then
                    option_error "Cannot find value of $arg"
                fi

                WAIT_FOR_EXEC_OPTION_ACTIONS[$long_option]="$fn|$value"
                continue
            fi
            
            # no value option
            WAIT_FOR_EXEC_OPTION_ACTIONS[$long_option]="$fn"

            continue
        elif [[ $i == 1 ]];then
            local is_command=false

            # walk commands
            for command_name command_metadata in ${(kv)COMMANDS}
            do  
                # exec next command
                if [[ $command_name == $arg ]];then
                    CURRENT_COMMAND_NAME=$command_name
                    is_command=true
                    break
                fi
            done

            if [[ $is_command == true ]];then
                continue
            fi
        fi

        # boundary
        if [[ $i == 1 ]];then
            command_error "Unknown command $arg"
        else
            option_error "Unknown value $arg"
        fi
    done

    exec_options
}