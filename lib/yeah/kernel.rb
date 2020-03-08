module Yeah
  module Kernel
    class << self
      # Request changing the user's directory in their shell
      #
      # #### Parameters
      # `path` : the path to change
      #
      def cd(path)
        @cd = path
      end

      # Set an environment variable in a user's shell instance
      #
      # #### Parameters
      # `key`   : the key of the environment variable
      # `value` : the value of the environment variable
      #
      def setenv(key, value)
        @setenv ||= {}
        @setenv[key] = value
      end

      # Finalize all requests to change a user's shell environment
      #
      def finish!
        commands = []
        requests = []

        if @cd
          requests << "cd:#{@cd}"
          commands << "cd #{@cd}"
        end

        (@setenv || {}).each do |k, v|
          requests << "setenv:#{k}=#{v}"
        end

        return if requests.empty?
        begin
          finalizer_pipe.puts(requests.join("\n"))
        rescue Errno::EBADF, IOError
          finalizers = []
          commands.each { |cmd| finalizers << "{{command:#{cmd}" }
          Output.abort(message: "Not running with shell integration. Run: #{finalizers.join(', ')}")
        ensure
          clear
        end
      end

      private

      def clear
        @cd = @setenv = nil
      end

      def finalizer_pipe
        IO.new(finalizer_fd)
      rescue ArgumentError => e
        ObjectSpace.each_object(IO) do |io|
          next if io.closed? || io.fileno != finalizer_fd
          raise CLI::Kit::Bug, "File descriptor #{io.fileno}, of type #{io.stat.ftype}, is not available."
        end
        raise e
      end

      def finalizer_fd
        9
      end
    end
  end
end
