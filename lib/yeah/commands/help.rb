require 'yeah'

module Yeah
  module Commands
    class Help < Yeah::Command
      def call(args, _name)
        if args.any?
          print_specific_help(args)
        else
          print_base_commands
          print_project_commands
        end
      end

      private

      def command_usage(name)
        "{{command:#{Yeah::TOOL_NAME} #{name}}}"
      end

      def print_specific_help(args)
        command = args.first
        klass = Yeah::Commands::Registry.lookup_command(command).first
        Output.abort(message: "Command {{command:#{command}}} not found") unless klass

        if current_project.custom_command_names.include?(command)
          print_project_command(command)
        else
          print_base_command(command, klass)
        end
      end

      def print_base_commands
        Output.print("{{bold:Base commands}}")

        Yeah::Commands::Registry.resolved_commands.each do |name, klass|
          next if name == 'help'
          Output.newline
          print_base_command(name, klass)
        end
      end

      def print_base_command(name, klass)
        Output.print(command_usage(name))
        Output.print(klass.help) if klass.help
      end

      def print_project_commands
        return unless current_project.custom_command_names.any?

        Output.newline
        Output.print("{{bold:Project Commands}}")

        current_project.custom_command_names.each do |name|
          Output.newline
          print_project_command(name)
        end
      end

      def print_project_command(name)
        definition = current_project.config['commands'][name]
        Output.print(command_usage(name))
        Output.print(definition['desc']) if definition['desc']
      end

      def current_project
        @current_project ||= Yeah::Project.current
      end
    end
  end
end
