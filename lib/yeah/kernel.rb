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
        message = []

        message << "cd:#{@cd}" if @cd
        (@setenv || {}).each do |k, v|
          message << "setenv:#{k}=#{v}"
        end

        return if message.empty?
        begin
          finalizer_pipe.puts(message.join("\n"))
        rescue Errno::EBADF, IOError
          $stderr.puts "Not running with shell integration. Run: #{message.join("\n")}"
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
        # Looks like finalizer_fd is in use, try to find it
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
