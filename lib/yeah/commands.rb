require 'yeah'

module Yeah
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: nil
    )

    def self.register(const, command_name = nil)
      filename = CLI::Kit::Util.snake_case(const)
      path = File.join('yeah/commands', filename)
      autoload(const, path)
      command_name ||= CLI::Kit::Util.dash_case(const)
      Registry.add(->() { const_get(const) }, command_name)
    end

    register :Goto
    register :Help
  end
end
