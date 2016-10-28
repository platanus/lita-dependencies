require 'json'
require 'date'
class GemEntry
  attr_accessor :gem_name, :version, :user, :project, :date

  def initialize(args)
    @gem_name = args[:gem_name]
    @version = args[:version]
    @user = args[:user]
    @project = args[:project]

    case args[:date].class
      when Date
        @date = args[:date]
      when String
        @date = Date.parse(args[:date])
      else
        @date = Date.today
    end
  end

  def ==(other_entry)
    gem_name == other_entry.gem_name && user == other_entry.user && project == other_entry.project
  end

  def dump
    {
        gem_name: gem_name,
        version: version,
        user: user,
        project: project,
        date: date
    }.to_json
  end

  def self.from_dump(_dump)
    args_hash = JSON.parse(_dump, symbolize_names: true)
    GemEntry.new(args_hash)
  end
end