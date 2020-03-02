require 'cli/ui'
require 'cli/kit'

CLI::UI::StdoutRouter.enable

module Yeah
  extend CLI::Kit::Autocall

  TOOL_NAME = 'yeah'
  ROOT      = File.expand_path('../..', __FILE__)
  LOG_FILE  = '/tmp/yeah.log'

  autoload(:EntryPoint, 'yeah/entry_point')
  autoload(:Commands,   'yeah/commands')

  autocall(:Config)  { CLI::Kit::Config.new(tool_name: TOOL_NAME) }
  autocall(:Command) { CLI::Kit::BaseCommand }

  autocall(:Executor) { CLI::Kit::Executor.new(log_file: LOG_FILE) }
  autocall(:Resolver) do
    CLI::Kit::Resolver.new(
      tool_name: TOOL_NAME,
      command_registry: Yeah::Commands::Registry
    )
  end

  autocall(:ErrorHandler) do
    CLI::Kit::ErrorHandler.new(
      log_file: LOG_FILE,
      exception_reporter: nil
    )
  end
end
