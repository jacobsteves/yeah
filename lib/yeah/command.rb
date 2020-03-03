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
      cmd.output("{{x}} {{red:Missing argument.}}")
      cmd.output(help)
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

    def call(_args, _command_name)
      raise NotImplementedError
    end

    def has_subcommands?
      false
    end

    def serialized_store_path
      File.expand_path('../../store', File.dirname(__FILE__))
    end
  end
end
