require 'yeah'

module Yeah
  module Commands
    module Resolver
      def self.aliases
        {}
      end

      def self.command_names
        Yeah::Project.current.custom_command_names
      end

      def self.command_class(_name)
        Yeah::Commands::Custom
      end
    end

    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: Resolver
    )

    def self.register(const, command_name = nil)
      load_const(const)
      command_name ||= CLI::Kit::Util.dash_case(const)
      Registry.add(->() { const_get(const) }, command_name)
    end

    def self.load_const(const)
      filename = CLI::Kit::Util.snake_case(const)
      path = File.join('yeah/commands', filename)
      autoload(const, path)
    end

    load_const :Custom
    register :Goto
    register :Help
  end
end
