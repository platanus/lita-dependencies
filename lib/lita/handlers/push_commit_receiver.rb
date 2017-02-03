require "lita-github-web-hooks-core"

module Lita
  module Handlers
    class GithubPushReceiver < Lita::Extensions::GitHubWebHooksCore::HookReceiver
      def self.name
        "GithubPushReceiver"
      end

      route("hello-dep") do |response|
        response.reply("hello hello, here we are, everything alright")
      end

      route(/please\signore\sgem\s+(.+)/) do |response|
        gem_name = response.matches[0][0]
        success = IgnoredGemsService.new(redis: redis).add_to_ignored(gem_name)
        if success
          response.reply("Ok dude. Added gem '#{gem_name}' to my ignore list")
        else
          response.reply("Epaah!  Gem '#{gem_name}' was already in the ignore list")
        end
      end

      route(/please\sconsider\sgem\s+(.+)/) do |response|
        gem_name = response.matches[0][0]
        success = IgnoredGemsService.new(redis: redis).remove_from_ignored(gem_name)
        if success
          response.reply("Ok dude, let's consider back gem '#{gem_name}'.\nRemoved from ignore list")
        else
          response.reply("Don't worry,  gem '#{gem_name}' is already considered and not in my ignore list right now")
        end
      end

      route(/please\sshow\signored\sgems/) do |response|
        gems = IgnoredGemsService.new(redis: redis).get_list
        if gems.empty?
          response.reply("No ignored gems by now")
        else
          response.reply("Let's see... ignored gems are:\n#{gems.join(', ')}")
        end
      end

      route(/please\sadd\steam\smember\s+(.+)/) do |response|
        name = response.matches[0][0]
        success = redis.sadd("team_members", name)
        if success
          response.reply("Ok dude. Added team member '#{gem_name}'")
        else
          response.reply("Epaah!  Team member '#{name}' was already in the list")
        end
      end

      route(/please\sremove\steam\smember\s+(.+)/) do |response|
        name = response.matches[0][0]
        success = redis.srem("team_members", name)
        if success
          response.reply("Ok dude, #{team_member} is not in the team anymore")
        else
          response.reply("Mmm sure? '#{gem_name}' is not found on my team list")
        end
      end

      route(/please\sshow\steam\smembers/) do |response|
        team_members = redis.smembers("team_members")
        if team_members.empty?
          response.reply("No team members by now")
        else
          response.reply("Let's see... team members are:\n#{team_members.join(', ')}")
        end
      end

      http.post "/github-web-hooks", :receive_hook

      on :push, :process

      def process(payload)
        entries = GithubService.gementries(payload)
        puts "recieved #{entries.nil? ? "nil" : entries.count} entries"
        messages = []
        entries.each do |entry|
          messages << ProcessEntry.for(entry: entry, redis: redis).to_s
        end

        unless messages.empty?
          messages.unshift "Tengo unas noticias GEMiales para ustedes! :deal-with-it:\n\n"
          messages.each { |message| robot.send_message(target, message) }
        end
      end

      private

      def target
        @target ||= Source.new(room: ENV.fetch("DEPENDENCIES_ROOM"))
      end

      Lita.register_handler(self)
    end
  end
end
