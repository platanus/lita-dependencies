require 'octokit'
require 'base64'
require 'net/http'

class GithubService
  # Builds an array of GemEntry
  def self.gementries(response)
    entries = []
    response["commits"].each do |commit|
      commit["modified"].each do |modif|
        if modif["Gemfile"] && modif["Gemfile.lock"].nil?
          file = fetch(response["repository"]["full_name"], modif, commit["id"])
          parse_file(file).each do |line|
            entries << GemEntry.new(
              gem_name: line[0],
              version: line[1],
              user: commit["author"]["name"],
              project: response["repository"]["name"]
            )
          end
        end
      end
    end
    entries
  end

  # Fetch a file from GitHub
  def self.fetch(repository, path, commit)
    client = Octokit::Client.new(
      login: ENV.fetch('GITHUB_LOGIN'),
      password: ENV.fetch('GITHUB_PASSWORD')
    )
    res = client.contents(repository, path: path, ref: commit)
    Base64.decode64(res.content)
  end

  # Parses a Gemfile
  def self.parse_file(file)
    list = []
    file.split("\n").each do |line|
      if line[0..3] == "gem "
        list << parse_line(line)
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
    line = line.split(",")[0..1]
    if line[1] && %r{[0-9.]}.match(line[1])
      line[1] = line[1]
    else
      line[1] = nil
    end
    line
  end
end
