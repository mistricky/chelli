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

## Get started
Chelli can help you create a CLI quickly, you can call `parse_cli` which is the only step to write a simple CLI.
```zsh
#!/bin/zsh
source ./chelli.sh

cli_parse $@
```

Perfect! so far you have your first own CLI create by Chelli, then you can try `-h, --help` or `-v, --version` to print information of the CLI.

## Build-in options
Basiclly, a CLI usually have a `-h, --help` option to show help information, also have `-v, --version` to display version information of this CLI, but fortunately is Chelli have two build-in options `-v, --version` and `-h, --help`, you can call `set_metadata` to complete CLI information and the two build-in options will use them to display later.

```zsh
#!/bin/zsh
source ./chelli.sh

# CLI name, CLI description, CLI version
set_metadata Foo "Whatever" "V1.0.0"

cli_parse $@
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

### Main command
Main command is current program that means is your running CLI.

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
```zsh
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
Of course, you can run any command with options, you just need to write option after the command, for instance:
```zsh
./foo.sh foo -n Jon
```
The `-n` is an option of the `foo` command, Chelli will parse the option and pass it into the hash table which name is `OPTION_VALUES` using `apply` function, this means is you can read value of each options via `OPTION_VALUES` hash table.

```zsh
#!/bin/zsh
#!/bin/zsh
source ../chelli.sh;

foo_command_action() {
  echo "the name is $OPTION_VALUES[name]"
  echo "foo is invoke!"
}

# the function will be invoke when the name option is parsed
name_option_action() {
    apply $1
}

# use optional argument
command "foo" "whatever" foo_command_action "[name]"
required_option "n" "name" "whatever" name_option_action "foo"

cli_parse $@
```

When the `name_option_action` is invoked, apply will set `$1`(value of name) into `OPTION_VALUES`, and then you can read the value of name from `OPTION_VALUES`, but the `apply` function doesn't get called automatically, this means that you have to call the `apply` funtion manually in action of the option.

Run the above code, you will see the name is print in the terminal.

```zsh
the name is Jon
foo is invoke!
```

## Options
Option is another from CLI arguments that usually start with `-` or `--`, and option is same to `arguments`, also have `required_option` and `option(optional option)`. And the `option` function take five arguments which is `short option name`, `long option name`, `description of the option`, `option action handler` and `bind command name`, It's worth mention that if `bind command name` is empty, option will bind on the `main command`.

Consider the following code:
```zsh
foo_action() {
  echo "foo action"
}

option "f" "foo" "description" foo_action
```

Add the above code in your code and run with `./cli_name.sh -f` that will print:
```zsh
foo action
```

And of course you can specify the comamnd that you wanna bind, you can just need to append the command name after the action argument just like:
```zsh
option "f" "foo" "description" foo_action "spycify_command_name"
```
Then run `./cli_name.sh spycify_command_name -f` you will see the result same to the above example.

### Required option
If you wanna pass a value to any option, you can use `required_option`, for instance:
```zsh
foo_action() {
  echo "value is $1"
}

required_option "f" "foo" "description" foo_action "spycify_command_name"
```

Then run with `./cli_name.sh -f bar`, you will see
```zsh
value is bar
```

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
