<p align="center">
  <img src="https://i.imgur.com/ljd1HY3.png" alt="Yeah Logo" height="80px" />
</p>

## Installation
1. Clone the repo
2. In your shell config (ie, `.bash_profile`, `.bashrc`, `.zshrc`, etc), set:

```bash
if [[ -f /your/path/to/yeah/yeah.sh ]]
then
    source /your/path/to/yeah/yeah.sh
fi
```
3. Reload your shell

## Commands

### Goto
- Change directories to a location indicated by a keyword.
- Usage: `yeah goto some_keyword [--set=<your directory>] [--delete] [--clear] [--list]`
- Example:
```
# Set new keyword: test
yeah goto test --set=/my/path

# Go to keyword: test
yeah goto test

# Delete keyword: test
yeah goto test --delete

# List all keywords
yeah goto --list

# Delete all keywords
yeah goto --clear
```

### Custom Commands
This is designed so that you can save different commands and execute them easily.
You can create a `yeah.yml` file and configure it. Under the `commands` scope, you can declare commands.
These commands can be run the same way as a regular command. For example, a command named `custom_test` can
be run by invoking `yeah custom_test`.

Take the following configuration, for example:

```yaml
# yeah.yml

commands:
  hello:
    desc: prints Hello World!
    run: echo "Hello world!"
```

Note that passing in arguments to custom scripts forwards the arguments to command.

```yaml
# yeah.yml

commands:
  install:
    desc: install dependencies via npm
    run: npm install
```

```
$ yeah install
npm output...
$ yeah install --silent # silent flag gets passed to npm install
```

#### Example Configuration
```yaml
# yeah.yml

name: yeah

commands:
  # yeah test
  test:
    run: rake test

  # yeah hello
  hello:
    desc: prints Hello World!
    run: echo "Hello world!"
    
  # yeah readme  
  readme:
    desc: An example command printing the readme.
    run:
      - echo 'Hello there!'
      - cat README.md
      
  # yeah rubocop    
  rubocop:
    desc: Runs the rubocop linter
    run: rubocop
    
  # yeah invalid  
  invalid:
    desc: Since this command has no run key, it should fail on execution
    
  # yeah another_invalid  
  another_invalid:
    desc: Cannot have nested actions.
    run:
      test: echo 'This is not allowed'
```
