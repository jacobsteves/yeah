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
      cmd.abort_with_help(args, command_name, message: "Missing argument.")
    rescue OptionParser::InvalidOption
      cmd.abort_with_help(args, command_name, message: "Invalid option.")
    rescue ConfigurationError => e
      cmd.abort(message: e.message)
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

    def abort_with_help(args, command_name, message: nil)
      abort(message: message) do
        call_help(args, command_name)
      end
    end

    def abort(message: nil)
      Output.error(message, newline: block_given?) if message
      yield if block_given?
      raise AbortSilent
    end

    def has_subcommands?
      false
    end
  end
end
