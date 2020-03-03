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
        "Goto your saved directories.\n"\
        "Usage: {{command:#{Yeah::TOOL_NAME} goto <name> [--set=dir] [--delete] [--list]}}"
      end

      private

      attr_accessor :data

      def serialized_store_path
        File.expand_path('goto', super)
      end

      def data
        @data ||= if File.exist?(serialized_store_path)
                  content = File.read(serialized_store_path)
                  content ? JSON.parse(content) : {}
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
