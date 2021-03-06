require 'yeah'

module Yeah
  module Commands
    class Custom < Yeah::Command
      def call(args, command_name)
        self.command_name = command_name
        cmd = command(command_name)
        raise_config_error unless cmd
        run(cmd, args)
      end

      private

      attr_accessor :command_name

      def config
        @config ||= Project.current.config
      end

      def commands
        @commands ||= config['commands'] || {}
      end

      def command(name)
        cmd = commands[name]
        valid_command(cmd) ? cmd : nil
      end

      def valid_command(cmd)
        return false unless cmd&.dig('run')
        cmd['run'].is_a?(Array) || cmd['run'].is_a?(String)
      end

      def raise_config_error
        raise Yeah::ConfigurationError,
              "The command {{command:#{command_name}}} within yeah.yml is not configured properly."
      end

      def run(definition, args = [])
        to_perform = definition['run']
        return execute(to_perform, args) unless to_perform.is_a?(Array)
        to_perform.each { |cmd| execute(cmd, args) }
      end

      def execute(cmd, args = [])
        raise_config_error unless cmd.is_a?(String)
        yeah_command = command(cmd)

        return run(yeah_command, args) if yeah_command
        raise Yeah::Abort, "{{x}} Task {{command:#{cmd}}} Failed." unless system([cmd, args].compact.join(" "))
      end
    end
  end
end
