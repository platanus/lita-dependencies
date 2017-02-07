class ProcessEntry < PowerTypes::Command.new(:entry, :redis)
  def perform
    puts "processing #{@entry.dump}"
    @previous_entries = get_previous_entries
    use_count = @previous_entries.count + 1

    # auto ignore without message if count is > 11
    ignore if use_count > 11

    puts "gem ignored?: #{ignored_gem? ? 'YES' : 'NO'}.  Use count: #{use_count}"
    store_entry unless repeated_entry?
    unless ignored_gem? || repeated_entry? || !from_team?
      puts "Will build message..."
      message = BuildMessage.for(entry: @entry, previous_entries: @previous_entries)
      if use_count == 11
        # notify for last time when count is 11
        message += "\nLa voy a empezar a ignorar porque ha sido usada más de 10 veces"
        ignore
      end
      message
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

  def ignore
    IgnoredGemsService.new(redis: @redis).add_to_ignored(@entry.gem_name)
  end

  def ignored_gem?
    @ignored_gem ||= @redis.sismember("ignored_gems", @entry.gem_name)
  end

  def repeated_entry?
    @previous_entries.include?(@entry)
  end

    def from_team?
    team_members.include?(@entry.user)
  end

  def team_members
    @team_members ||= @redis.smembers("team_members")
  end
end