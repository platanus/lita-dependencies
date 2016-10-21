require "lita-github-web-hooks-core"

module Lita
  module Handlers
    class GithubPushReceiver < Lita::Extensions::GitHubWebHooksCore::HookReceiver
      def self.name
        "GithubPushReceiver"
      end

      http.post "/github-web-hooks", :receive_hook

      on :push, :receive

      def receive(payload)
        gem_entries = GithubService.gementries(payload, Lita.logger)
        # message = ProcessEntries.for gem_entries
        # robot.send_message()
      end
      Lita.register_handler(self)
    end
  end
end
