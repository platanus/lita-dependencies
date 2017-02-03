class IgnoredGemsService < PowerTypes::Service.new(:redis)
  def add_to_ignored(gem_name)
    return false if @redis.sismember("ignored_gems", gem_name)
    @redis.sadd("ignored_gems", gem_name)
    true
  end

  def remove_from_ignored(gem_name)
    return false unless @redis.sismember("ignored_gems", gem_name)
    @redis.srem("ignored_gems", gem_name)
    true
  end

  def get_list
    @redis.smembers("ignored_gems")
  end
end