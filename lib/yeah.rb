require 'cli/ui'
require 'cli/kit'

CLI::UI::StdoutRouter.enable

module Yeah
  extend CLI::Kit::Autocall

  TOOL_NAME = 'yeah'
  ROOT      = File.expand_path('../..', __FILE__)
  LOG_FILE  = '/tmp/yeah.log'

  Abort        = CLI::Kit::Abort
  AbortSilent  = CLI::Kit::AbortSilent
  Bug          = CLI::Kit::Bug
  BugSilent    = CLI::Kit::BugSilent
  GenericAbort = CLI::Kit::GenericAbort

  autoload(:Command,    'yeah/command')
  autoload(:Commands,   'yeah/commands')
  autoload(:EntryPoint, 'yeah/entry_point')
  autoload(:Kernel,     'yeah/kernel')
  autoload(:Options,    'yeah/options')
  autoload(:Project,    'yeah/project')

  autocall(:Config)  { CLI::Kit::Config.new(tool_name: TOOL_NAME) }

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
