# Yeah

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

## Usage

```yaml
# yeah.yml

name: yeah

commands:
  test:
    run: rake test
  hello:
    desc: prints Hello World!
    run: echo "Hello world!"
  readme:
    desc: An example command printing the readme.
    run:
      - echo 'Hello there!'
      - cat README.md
  rubocop:
    desc: Runs the rubocop linter
    run: rubocop
  invalid:
    desc: Since this command has no run key, it should fail on execution
  another_invalid:
    desc: Cannot have nested actions.
    run:
      test: echo 'This is not allowed'
```
