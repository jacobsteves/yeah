require 'yeah'

module Yeah
  module Commands
    class Help < Yeah::Command
      def call(args, _name)
        Output.print("{{bold:Base commands}}")

        Yeah::Commands::Registry.resolved_commands.each do |name, klass|
          next if name == 'help'
          Output.newline
          Output.print(command_usage(name))
          if help = klass.help
            Output.print(help)
          end
        end

        project = Yeah::Project.current
        if project.custom_command_names.any?
          Output.newline
          Output.print("{{bold:Project Commands}}")

          project.custom_command_names.each do |name|
            Output.newline
            definition = project.config['commands'][name]
            Output.print(command_usage(name))
            Output.print(definition['desc']) if definition['desc']
          end
        end
      end

      private

      def command_usage(name)
        "{{command:#{Yeah::TOOL_NAME} #{name}}}"
      end
    end
  end
end
