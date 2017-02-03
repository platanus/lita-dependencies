class ProcessEntry < PowerTypes::Command.new(:entry, :redis)
  def perform
    puts "processing #{@entry.dump}"
    puts "gem ignored?: #{ignored_gem? ? 'YES' : 'NO'}"
    @previous_entries = get_previous_entries
    puts "fetched #{@previous_entries.nil? ? "nil" : @previous_entries.count} previous entries"
    store_entry unless repeated_entry?
    unless ignored_gem? || repeated_entry? || !from_team?
      puts "Will build message..."
      BuildMessage.for(entry: @entry, previous_entries: @previous_entries)
    end
  end

  private

  def store_entry
    puts "stored entry"
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

    def from_team?
    @team_members.include?(@entry.user)
  end

  def team_members
    @team_members ||= @redis.smembers("team_members")
  end
end