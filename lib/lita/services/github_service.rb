require 'octokit'
require 'base64'
require 'net/http'

class GithubService
  def self.fetch(repository, path, commit)
    client = Octokit::Client.new(
      login: ENV.fetch('GITHUB_LOGIN'),
      password: ENV.fetch('GITHUB_PASSWORD')
    )
    res = client.contents(repository, path: path, ref: commit)
    Base64.decode64(res.content)
  end

  def self.gementries(response, logger)
    response["commits"].each do |commit|
      commit["modified"].each do |modif|
        # if modif["Gemfile"] && modif["Gemfile.lock"].nil? 
        logger.debug self.fetch(response["repository"]["full_name"], modif, commit["id"])
        # end
      end
    end
  end
end
