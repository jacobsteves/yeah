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
          return if CLI::Kit::System.system('cd', data[key])
          puts CLI::UI.fmt("{{x}} {{red:Error}}\nUnable to change to directory: #{data[key]}.")
        else
          puts CLI::UI.fmt("{{x}} {{red:Error}}\nCommand: #{key} hasn't been set yet.")
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
        puts CLI::UI.fmt("{{v}} Key successfully set.")
      end

      def delete_key(key)
        value = data[key]
        data.delete(key)
        data = data || {}
        write_data
        puts CLI::UI.fmt("Key {{cyan:#{key}}} with value {{cyan:#{value}}} was deleted.")
      end

      def list
        puts CLI::UI.fmt("Listing saved locations.")
        data.each do |key, value|
          puts CLI::UI.fmt("{{cyan:#{key}}}: #{value}")
        end
      end
    end
  end
end