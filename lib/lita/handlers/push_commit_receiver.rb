require "lita-github-web-hooks-core"

module Lita
  module Handlers
    class GithubPushReceiver < Lita::Extensions::GitHubWebHooksCore::HookReceiver
      def self.name
        "GithubPushReceiver"
      end

      route("hello-dep") do |response|
        response.reply("hello my friend! I'm alive")
      end

      route(/please\signore\sgem\s+(.+)/) do |response|
        gem_name = response.matches[0][0]
        success = add_to_ignored(gem_name)
        if success
          response.reply("Ok dude. Added gem '#{gem_name}' to my ignore list")
        else
          response.reply("Epaah!  Gem '#{gem_name}' was already in the ignore list")
        end
      end

      route(/please\sconsider\sgem\s+(.+)/) do |response|
        gem_name = response.matches[0][0]
        success = remove_from_ignored(gem_name)
        if success
          response.reply("Ok dude, let's consider back gem '#{gem_name}'.\nRemoved from ignore list")
        else
          response.reply("Don't worry,  gem '#{gem_name}' is already considered and not in my ignore list right now")
        end
      end

      route(/please\sshow\signored\sgems/) do |response|
        gems = ignored_gems_list
        if gems.empty?
          response.reply("No ignored gems by now")
        else
          response.reply("Let's see... ignored gems are:\n#{gems.join(', ')}")
        end
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

      private

      def target
        @target ||= Source.new(room: ENV.fetch("DEPENDENCIES_ROOM"))
      end

      def add_to_ignored(gem_name)
        return false if redis.sismember("ignored_gems", gem_name)
        redis.sadd("ignored_gems", gem_name)
        true
      end

      def remove_from_ignored(gem_name)
        return false unless redis.sismember("ignored_gems", gem_name)
        redis.srem("ignored_gems", gem_name)
        true
      end

      def ignored_gems_list
        redis.smembers("ignored_gems")
      end

      def temp_entries
        [
            GemEntry.new(gem_name: "devise",user: "felbalart",version: "1.01",project: "ninja-markets",date:"2016-10-02"),
            GemEntry.new(gem_name: "devise",user: "mariolopez",version: "1.01",project: "surbtc",date:"2016-05-12")
        ]
    end

      Lita.register_handler(self)
    end
  end
end
