class AddToIgnored < PowerTypes::Command.new(:gem_name, :redis)
  def perform
    return if @redis.sismember("ignored_gems", @gem_name)
    @redis.sadd("ignored_gems", @gem_name)
  end
end