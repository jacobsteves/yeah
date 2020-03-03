require 'yeah'

module Yeah
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: nil
    )

    def self.register(const, cmd, path)
      autoload(const, path)
      Registry.add(->() { const_get(const) }, cmd)
    end

    register :Example, 'example', 'yeah/commands/example'
    register :Goto,    'goto',    'yeah/commands/goto'
    register :Help,    'help',    'yeah/commands/help'
  end
end