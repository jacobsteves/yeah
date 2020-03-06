module Yeah
  class Output
    def self.print(*lines, newline: false)
      lines.each { |line| puts CLI::UI.fmt("#{line}") }
      self.newline if newline
    end

    def self.error(*lines, newline: false)
      $stderr.puts CLI::UI.fmt("{{x}} {{red:Error}}")
      lines.each { |line| $stderr.puts CLI::UI.fmt("#{line}") }
      self.newline(out: $stderr) if newline
    end

    def self.warning(*lines, newline: false)
      puts CLI::UI.fmt("{{warning:Warning}}")
      lines.each { |line| puts CLI::UI.fmt("#{line}") }
      self.newline if newline
    end

    def self.newline(out: $stdout)
      out.puts "\n"
    end
  end
end
