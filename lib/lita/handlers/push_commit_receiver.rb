require "lita-github-web-hooks-core"

module Lita
  module Handlers
    class GithubPushReceiver < Lita::Extensions::GitHubWebHooksCore::HookReceiver
      def self.name
        "GithubPushReceiver"
      end

      http.post "/github-web-hooks", :receive_hook

      on :push, :store

      def store(payload)
        # payload = JSON.parse(payload)
        repository_name = payload["repository"]["name"]
        Lita.logger.debug("Excelent! Someone has commited to '#{repository_name}'")
        payload["commits"].each do |commit|
          commit["modified"].each do |modif|
            Lita.logger.debug("- #{modif}")
          end
        end
      end
     
      Lita.register_handler(self)
    end
  end
end
