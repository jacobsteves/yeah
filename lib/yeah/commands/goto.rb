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

        name = args.first
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
        "    {{command:--list}},      {{command: -l}}          - List all saved entries <name>"
      end

      private

      attr_accessor :data

      def serialized_store_path
        File.expand_path('goto', super)
      end

      def data
        @data ||= if File.exist?(serialized_store_path)
                    begin
                      content = File.read(serialized_store_path)
                      content ? JSON.parse(content) : {}
                    rescue JSON::ParserError
                      warning("Your saved data has been corrupted and could not be retrieved.")
                      {}
                      end
                  else
                    {}
                  end
      end

      def goto(key)
        if data[key]
          return Yeah::Kernel.cd(data[key]) if File.exist?(data[key])
          error("No such file or directory: #{data[key]}.")
        else
          error("Command: #{key} hasn't been set yet.")
        end
      end

      def write_data
        content = JSON.pretty_generate(data)
        File.open(serialized_store_path, 'w') do |f|
          f.write(content)
        end
      end

      def set_key(key, value)
        data[key] = value
        write_data
        output("{{v}} Key successfully set.")
      end

      def delete_key(key)
        value = data[key]
        data.delete(key)
        data = data || {}
        write_data
        output("Key {{cyan:#{key}}} with value {{cyan:#{value}}} was deleted.")
      end

      def list
        if data.empty?
          output("No locations saved yet.")
          output(self.class.help)
          return
        end

        output("Listing saved locations.")
        data.each do |key, value|
          output("{{cyan:#{key}}}: #{value}")
        end
      end
    end
  end
end
