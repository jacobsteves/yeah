require 'yeah'
require 'json'

module Yeah
  module Commands
    class Goto < Yeah::Command
      parses_options

      options do |parser, flags|
        parser.on('--set=dir') { |flag| flags[:set] = flag }
        parser.on('--delete') { |flag| flags[:delete] = flag }
        parser.on('--list') { |flag| flags[:list] = flag }
        parser.on('--clear') { |flag| flags[:clear] = flag }
      end

      def call(args, _name)
        return list if options.flags[:list]
        return clear if options.flags[:clear]

        name = args.first&.to_sym
        raise ArgumentError unless name

        if options.flags[:delete]
          delete(name)
        elsif options.flags[:set]
          set(name, options.flags[:set])
        else
          goto(name)
        end
      end

      def self.help
        "Goto the directory associated with <key>.\n"\
        "Usage: {{command:#{Yeah::TOOL_NAME} goto <key> [--set <dir>] [--clear] [--delete] [--list]}}\n\n"\
        "  Options:\n"\
        "    {{command:--set <dir>}}, {{command: -s <dir>}}    - Save entry <key> with value <dir>\n"\
        "    {{command:--clear}},     {{command: -c}}          - Delete all saved entries\n"\
        "    {{command:--delete}},    {{command: -d}}          - Delete entry <key>\n"\
        "    {{command:--list}},      {{command: -l}}          - List all saved entries"
      end

      private

      def goto(key)
        if store.exists?(key)
          path = store.get(key)
          return Yeah::Kernel.cd(path) if File.exist?(path)
          Output.abort("No such file or directory: #{path}.")
        else
          Output.abort("Command: #{key} hasn't been set yet.")
        end
      end

      def clear
        Output.abort(message: 'No active keywords to be deleted.') if store.empty?

        ans = CLI::UI.ask('Delete all stored goto data?', options: %w(yes no))
        return Output.print('Canceled.') if ans == 'no'

        CLI::UI::Spinner.spin('Deleting..') do |spinner|
          sleep 0.7
          spinner.update_title('Ahh let me double check..')
        end

        ans = CLI::UI.ask('Are you super sure?', options: ['I promise, clear all data', 'cancel'])
        return Output.print('Canceled.') if ans == 'cancel'

        CLI::UI::Spinner.spin('Deleting for real..') do |spinner|
          store.clear
          spinner.update_title('Deleted.')
        end
      end

      def set(key, value)
        store.set("#{key}": value)
        Output.print("{{v}} Key successfully set.")
      end

      def delete(key)
        if store.exists?(key)
          value = store.get(key)
          store.delete(key)
          Output.print("Key {{cyan:#{key}}} with value {{cyan:#{value}}} was deleted.")
        else
          Output.abort(message: "Key {{cyan:#{key}}} has not been set.")
        end
      end

      def list
        if store.empty?
          Output.print("No locations saved yet.")
          Output.print(self.class.help)
          return
        end

        Output.print("Listing saved locations.")
        store.each do |key, value|
          Output.print("{{cyan:#{key}}}: #{value}")
        end
      end

      def store
        @store ||= Yeah::Store.new(filename: 'goto')
      end
    end
  end
end
