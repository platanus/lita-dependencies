require_relative 'build_message'
require "redis"

class ProcessEntry < PowerTypes::Command.new(:entry, :redis)
  def perform
    @previous_entries = get_previous_entries  unless ignored_gem?
    store_entry unless repeated_entry?
    BuildMessage.for(entry: @entry, previous_entries: @previous_entries) unless ignored_gem? || repeated_entry?
  end

  def store_entry
    @redis.sadd(@entry.gem_name, @entry.dump)
  end

  def get_previous_entries
    @redis.smembers(@entry.gem_name).map do |entry_json|
      GemEntry.from_dump(entry_json)
  end.sort_by(&:date).reverse
  end

  def ignored_gem?
    @ignored_gem ||= @redis.sismember("ignored_gems", @entry.gem_name)
  end

  def repeated_entry?
    @previous_entries.include?(@entry)
  end
end