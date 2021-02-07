<div>
  <p align="center"><img width=250 src="https://github.com/youncccat/chelli/blob/main/doc/logo.png" alt="Chelli"></p>
</div>
<p align="center">
  <h1 align="center">Chelli</h1>
</p>

Chelli is a function set that implements command-line parsing using Zsh Shell. And the name of Chelli means a combination of Shell and CLI.

## Installation
Chelli is a set of Zsh functions, so you just need to import Chelli into your source file like the following code snippet.
```zsh
source your_chelli_path/chelli.sh

# your source code
```

## Build-in options
Basiclly, a CLI usually have a `-h, --help` option to show help information, also have `-v, --version` to display version information of this CLI, but fortunately is Chelli have two build-in options `-v, --version` and `-h, --help`, you can call `set_metadata` to complete CLI information and the two build-in options will use them to display later.

```zsh
#!/bin/zsh
source ./chelli.sh

# CLI name, CLI description, CLI version
set_metadata Foo "Whatever" "V1.0.0"
```
Let's take a look help information of the "Foo", run `./foo.sh -h` you will get the following output in your terminal.

```zsh
Whatever

Usage: Foo [options] commands

Options:

-v, --version   Print version information & quit
-h, --help   Print handbook & quit
```
That's easy right? also you can print version information via `./foo.sh -v`.
```
Foo version V1.0.0
```

And It's worth mention that the build-in option which just like `-h, --help` and `-v, --version` is implemented using `option` function by Chelli, so you can override the two build-in option if you wanna display the information you wanna display or something like that.

This code snippet from Chelli:
```zsh
# build-in options
option "v" "version" "Print version information & quit" print_version
option "h" "help" "Print handbook & quit" print_help "*"
```
You might notice that there is an `*` in above codes, this is a `Wildcard character` in Chelli, for more detail see [Options](https://github.com/youncccat/chelli#options).

## Commands
Commands is an important part of CLI, you can using `command` function to define your command. The `command` function take four arguments which are `name`, `description`, `action handler` and `arguments`.

In this case which is simplest usage of `command`.
```zsh
#!/bin/zsh
source ../chelli.sh;

foo_command_action() {
  echo "foo is invoke!"
}

command "foo" "whatever" foo_command_action

cli_parse $@
```

> Notice: the `arguments` is a optional argument, so you can call `command` without `arguments`, just like the above code.

When you run `./foo.sh foo` you will see:
```zsh
foo is invoke!
```

### Run command with arguments
In addition, you can run command with arguments which just like `cli command <arg> [arg]` or something like that, Chelli will parse the arguments and pass them into corresponding action of the command.

#### Required argument
the `<args>` is enclosed by angle brackets that meaning the `<arg>` is required argument, consider the following code.

```zsh
#!/bin/zsh
source ../chelli.sh;

# the first argument is the value of name
foo_command_action() {
  echo "the name is $1"
  echo "foo is invoke!"
}

command "foo" "whatever" foo_command_action "<name>"

cli_parse $@
```

If you run `./foo.sh foo Jon`, you will see the following output:
```zsh
the name is Jon
foo is invoke!
```
But if you forget to write the name argument like `./foo foo`, then you will get the following error and the program will crash.
```zsh
[Argument Error]: The name argument is required
```

#### Optional argument
The `optional argument` is same to `required argument` which is only difference between them is the `optional argument` is you can run command without the `optionl argument` just like the name of it.

Let's update the above codes like:
```
#!/bin/zsh
source ../chelli.sh;

# the first argument is the value of name
foo_command_action() {
  echo "the name is $1"
  echo "foo is invoke!"
}

# use optional argument
command "foo" "whatever" foo_command_action "[name]"

cli_parse $@
```
Output:
```zsh
the name is 
foo is invoke!
```
You may have notice that if the `name` argument is missing when call the `foo` command, the action handler of `foo` command receives the value of `name` is `""`, but you can't see any error same by `required argument`.

> Notice: the value of each arguments will passed as function arguments to the corresponding action of the command

### Run command with options 

## Options

## Examples
You can found an example that is used to simulate the behavior of login into the database. Following is some code snippets, for more detail see **[access.sh](https://github.com/youncccat/chelli/blob/main/examples/access.sh)**.

```zsh
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
```

[![asciicast](https://asciinema.org/a/389532.svg)](https://asciinema.org/a/389532)

As you can see everything is working fine🎉

## LICENSE
MIT.
