require "lita"
require "lita/services/github_service"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/push_commit_receiver"

Lita::Handlers::GithubPushReceiver.template_root File.expand_path(
  File.join("..", "..", "templates"), __FILE__
)
