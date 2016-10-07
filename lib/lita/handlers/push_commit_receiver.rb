require "lita-github-web-hooks-core"

module Lita
  module Handlers
    class GithubPushReceiver < Lita::Extensions::GitHubWebHooksCore::HookReceiver
      def self.name
        "GithubPushReceiver"
      end

      http.post "/github-web-hooks", :receive_hook

      on :push, :store
      on :ping, :just_ping

      def logger
        Lita.logger
      end

      def store(_payload)
        logger.debug("Payload received")
      end

      def just_ping(_payload)
        logger.debug("Ping received from Github with success!")
      end

      Lita.register_handler(self)
    end
  end
end
