require 'lita-github-web-hooks-core'

module Lita
  module Handlers
    class GithubPushReceiver < Lita::Extensions::GitHubWebHooksCore::HookReceiver
      def self.name
        "GithubPushReceiver"
      end

      http.post "/github-web-hooks", :receive_hook

      on :push, :process_push

      def process_push
      	binding.pry
      end

      Lita.register_handler(self)
    end
  end
end
