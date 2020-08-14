module Yeah
  class Output
    def self.print(*lines, newline: false)
      lines.each { |line| puts CLI::UI.fmt(line.to_s) }
      self.newline if newline
    end

    def self.error(*lines, newline: false)
      $stderr.puts CLI::UI.fmt("{{x}} {{red:Error}}")
      lines.each { |line| $stderr.puts CLI::UI.fmt(line.to_s) }
      self.newline(out: $stderr) if newline
    end

    def self.warning(*lines, newline: false)
      puts CLI::UI.fmt("{{warning:Warning}}")
      lines.each { |line| puts CLI::UI.fmt(line.to_s) }
      self.newline if newline
    end

    def self.newline(out: $stdout)
      out.puts "\n"
    end

    def self.abort(message: nil)
      error(message, newline: block_given?) if message
      yield if block_given?
      raise AbortSilent
    end
  end
end
