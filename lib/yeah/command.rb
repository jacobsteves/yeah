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
      cmd.error("Missing argument.")
      cmd.output('')
      cmd.call_help(args, command_name)
    rescue OptionParser::InvalidOption
      cmd.error("Invalid option.")
      cmd.output('')
      cmd.call_help(args, command_name)
    end

    def self.options(&block)
      @_options = block
    end

    def output(text)
      puts CLI::UI.fmt(text)
    end

    def error(text)
      puts CLI::UI.fmt("{{x}} {{red:Error}}")
      puts CLI::UI.fmt("#{text}")
    end

    def warning(text)
      puts CLI::UI.fmt("{{warning:Warning}}")
      puts CLI::UI.fmt("#{text}")
      puts "\n"
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
