require 'yeah'
require 'optparse'

module Yeah
  class Options
    attr_reader :flags, :help

    def initialize
      @flags = {}
      @help = false
    end

    def parse(options_block, args)
      @args = args
      if options_block.respond_to?(:call) && args
        parse_flags(options_block)
      else
        parser.permute!(@args)
      end
      @args
    end

    def parse_flags(block)
      block.call(parser, @flags)
      parser.permute!(@args)
    end

    def parser
      @parser ||= begin
        opt = OptionParser.new
        opt.on('--help', '-h', 'Print help for command') do |v|
          @help = v
        end
      end
    end
  end
end
