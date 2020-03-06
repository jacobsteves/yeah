require 'cli/kit'

module Yeah
  class Command < CLI::Kit::BaseCommand
    attr_accessor :options

    def self.call(args, command_name)
      cmd = new
      cmd.options = Options.new
      cmd.options.parse(@_options, args)
      cmd.call(args, command_name)
    rescue OptionParser::MissingArgument, ArgumentError
      Output.error("Missing argument.", newline: true)
      cmd.call_help(args, command_name)
    rescue OptionParser::InvalidOption
      Output.error("Invalid option.", newline: true)
      cmd.call_help(args, command_name)
    end

    def self.options(&block)
      @_options = block
    end

    def call(_args, _command_name)
      raise NotImplementedError
    end

    def call_help(args, command_name)
      help = Commands::Help.new
      help.call(args, command_name)
    end

    def has_subcommands?
      false
    end
  end
end
