require "gems"
class GetGemInfo < PowerTypes::Command.new(:name)
  def perform
    data = Gems.info @name
    return nil unless data.is_a? Hash
    {
      description: data["info"].to_s.gsub("\n"," "),
      uri: data["homepage_uri"].to_s.sub(/https?:\/\//,"")
    }
  rescue JSON::ParserError
    nil
  end
end