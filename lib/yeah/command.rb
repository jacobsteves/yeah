require 'cli/kit'
require 'optparse'

module Yeah
  class Command < CLI::Kit::BaseCommand
    attr_accessor :options

    def self.call(args, command_name)
      cmd = new
      cmd.configure_options(@_options, args) if parses_options?
      cmd.call(args, command_name)
    rescue OptionParser::MissingArgument, ArgumentError
      cmd.abort_with_help(args, command_name, message: "Missing argument.")
    rescue OptionParser::InvalidOption
      cmd.abort_with_help(args, command_name, message: "Invalid option.")
    end

    def self.options(&block)
      @_options = block
    end

    def self.parses_options?
      @_parses_options
    end

    def self.parses_options
      @_parses_options = true
    end

    def configure_options(options, args)
      self.options = Options.new
      self.options.parse(options, args)
    end

    def call(_args, _command_name)
      raise NotImplementedError
    end

    def call_help(args, command_name)
      help = Commands::Help.new
      help.call(args, command_name)
    end

    def abort_with_help(args, command_name, message: nil)
      Output.abort(message: message) do
        call_help(args, command_name)
      end
    end

    def has_subcommands?
      false
    end
  end
end
