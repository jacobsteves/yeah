module Yeah
  class Project
    class << self
      def current
        at(Dir.pwd)
      end

      def at(dir)
        proj_dir = directory(dir)
        raise Yeah::Abort, "A Yeah project does not exist here. Create a yeah.yml file." unless proj_dir
        @at ||= Hash.new { |h, k| h[k] = new(directory: k) }
        @at[proj_dir]
      end

      private

      def directory(dir)
        return nil if dir.nil?
        @dir ||= Hash.new { |h, k| h[k] = directory_with_config(k) }
        @dir[dir]
      end

      def directory_with_config(curr)
        loop do
          return nil if curr == '/'
          file = File.join(curr, 'yeah.yml')
          return curr if File.exist?(file)
          curr = File.dirname(curr)
        end
      end
    end

    attr_reader :directory

    def initialize(directory: './')
      @directory = directory
    end

    def config
      @config ||= begin
        config = load_yaml_file('yeah.yml')
        raise Yeah::Abort, "yeah.yml is not formatted properly." unless config.is_a?(Hash)
        config
      end
    end

    def custom_command_names
      config['commands']&.keys || []
    end

    private

    def load_yaml_file(relative_path)
      f = File.join(directory, relative_path)
      require 'yaml'
      begin
        YAML.load_file(f)
      rescue Psych::SyntaxError => e
        raise Yeah::Abort, "#{relative_path} could not be read: #{e.message}"
      end
    end
  end
end
