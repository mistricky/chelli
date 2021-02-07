#!/bin/zsh

source ../chelli.sh

print_arg_info() {
    echo "addr: $1"
    echo "branch: $2"
}

fetch() {
    print_arg_info $@
    echo "Fetch successful!"
}

pull_rebase() {
    echo "rebase!"
}

pull() {
    print_arg_info $@
    echo "Pull successful!"
}

push() {
    print_arg_info $@
    echo "Push successful!"
}

set_metadata git-cli "Git is a free and open source distributed version control system"

command "fetch" "Download objects and refs from another repository" fetch "<addr>" "<branch>"
command "push" "Push the codes to remote repository" push "<addr> <branch>"
command "pull" "Control for recursive fetching of submodules" pull "<addr> <branch>"

option "r" "rebase" "Override history" fetch_rebase pull

cli_parse $@