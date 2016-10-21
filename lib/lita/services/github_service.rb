require 'octokit'
require 'base64'
require 'net/http'

class GithubService
  # Fetch a file from GitHub
  def self.fetch(repository, path, commit)
    client = Octokit::Client.new(
      login: ENV.fetch('GITHUB_LOGIN'),
      password: ENV.fetch('GITHUB_PASSWORD')
    )
    res = client.contents(repository, path: path, ref: commit)
    Base64.decode64(res.content)
  end

  # Builds an array of GemEntry
  def self.gementries(response, logger)
    entries = []
    response["commits"].each do |commit|
      commit["modified"].each do |modif|
        if modif["Gemfile"] && modif["Gemfile.lock"].nil? 
          e = GemEntry.new
          
          self.fetch(response["repository"]["full_name"], modif, commit["id"])

        end
      end
    end
    entries
  end

  # Builds a Gemfile
  def self.parse_file(file)
    list = []
    file.split("\n").each do |line|
      if line[0..3] == "gem "
        list << self.parse_line(line)
      end
    end
    list
  end

  # Parse a gem line
  def self.parse_line(line)
    line.gsub!("gem ", "")
    line.gsub!(" ", "")
    line.gsub!("\"", "")
    line.gsub!("'", "")
    line.split(",")[0..1]
  end
end
