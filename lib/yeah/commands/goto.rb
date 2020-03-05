require 'yeah'
require 'json'

module Yeah
  module Commands
    class Goto < Yeah::Command
      options do |parser, flags|
        parser.on('--set=dir') { |flag| flags[:set] = flag }
        parser.on('--delete') { |flag| flags[:delete] = flag }
        parser.on('--list') { |flag| flags[:list] = flag }
      end

      def call(args, _name)
        return list if options.flags[:list]

        name = args.first&.to_sym
        raise ArgumentError unless name

        if options.flags[:delete]
          delete_key(name)
        elsif options.flags[:set]
          set_key(name, options.flags[:set])
        else
          goto(name)
        end
      end

      def self.help
        "Goto the directory associated with <key>.\n"\
        "Usage: {{command:#{Yeah::TOOL_NAME} goto <key> [--set <dir>] [--delete] [--list]}}\n\n"\
        "  Options:\n"\
        "    {{command:--set <dir>}}, {{command: -s <dir>}}    - Save entry <key> with value <dir>\n"\
        "    {{command:--delete}},    {{command: -d}}          - Delete entry <key>\n"\
        "    {{command:--list}},      {{command: -l}}          - List all saved entries"
      end

      private

      def goto(key)
        if store.exists?(key)
          path = store.get(key)
          return Yeah::Kernel.cd(path) if File.exist?(path)
          error("No such file or directory: #{path}.")
        else
          error("Command: #{key} hasn't been set yet.")
        end
      end

      def set_key(key, value)
        store.set("#{key}": value)
        output("{{v}} Key successfully set.")
      end

      def delete_key(key)
        value = store.get(key)
        store.delete(key)
        output("Key {{cyan:#{key}}} with value {{cyan:#{value}}} was deleted.")
      end

      def list
        if store.empty?
          output("No locations saved yet.")
          output(self.class.help)
          return
        end

        output("Listing saved locations.")
        store.each do |key, value|
          output("{{cyan:#{key}}}: #{value}")
        end
      end

      def store
        @store ||= Yeah::Store.new(filename: 'goto')
      end
    end
  end
end
