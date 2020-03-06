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
      cmd.fail_with_help(args, command_name, "Missing argument.")
    rescue OptionParser::InvalidOption
      cmd.fail_with_help(args, command_name, "Invalid option.")
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

    def fail_with_help(args, command_name, message = nil)
      Output.error(message, newline: true) if message
      call_help(args, command_name)
      raise AbortSilent
    end

    def has_subcommands?
      false
    end
  end
end
