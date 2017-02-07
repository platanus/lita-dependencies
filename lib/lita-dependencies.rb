require "lita"
require "redis"
require "power-types"
require "gems"
require "lita/models/gem_entry"
require "lita/services/github_service"
require "lita/commands/build_message"
require "lita/commands/process_entry"
require "lita/commands/get_gem_info"
require "lita/services/ignored_gems_service"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/push_commit_receiver"

Lita::Handlers::GithubPushReceiver.template_root File.expand_path(
  File.join("..", "..", "templates"), __FILE__
)
