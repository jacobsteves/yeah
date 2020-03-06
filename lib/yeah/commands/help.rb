require 'yeah'

module Yeah
  module Commands
    class Help < Yeah::Command
      def call(args, _name)
        Output.print("{{bold:Available commands}}", newline: true)

        Yeah::Commands::Registry.resolved_commands.each do |name, klass|
          next if name == 'help'
          Output.print("{{command:#{Yeah::TOOL_NAME} #{name}}}")
          if help = klass.help
            Output.print(help)
          end
          Output.newline
        end
      end
    end
  end
end
