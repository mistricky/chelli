#!/bin/zsh

source ../chelli.sh;

login() {
    echo "Login user: " $OPTION_VALUES[user]
    echo "Login password: " $OPTION_VALUES[password]
    echo "Login database: " $OPTION_VALUES[database]
    echo
    echo "Login..."
}

# username
specify_user() {
    apply $1
}

enter_password() {
    local password
    printf "password: "
    read -s password

    apply $password
}

specify_database() {
    apply $1
}

set_metadata access "Access database tool" "V1.0.2"

command login "Login to the specified database" login

required_option "u" "user" "Specify the user that needs to be login" specify_user login
required_option "d" "database" "Specify the database that needs to be login" specify_database login
option "p" "password" "User password" enter_password login

cli_parse $@
