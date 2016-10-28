require "lita-github-web-hooks-core"

module Lita
  module Handlers
    class GithubPushReceiver < Lita::Extensions::GitHubWebHooksCore::HookReceiver
      def self.name
        "GithubPushReceiver"
      end

      http.post "/github-web-hooks", :receive_hook

      on :push, :process

      def process(payload)
        entries = GithubService.gementries(payload)
        message = ""
        entries.each do |entry|
          message += ProcessEntry.for(entry: entry, redis: redis).to_s
        end

        unless message == ""
          message = "Tengo unas noticias GEMiales para ustedes! :deal-with-it:\n\n" + message
          robot.send_message(target, message)
        end
      end

      def target
        @target ||= Source.new(room: ENV.fetch("SLACK_ROOM_NAME"))
      end
      Lita.register_handler(self)
    end
  end
end
