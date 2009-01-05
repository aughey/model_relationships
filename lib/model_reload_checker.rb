class ModelReloadChecker
  def self.needs_reloading?
    if @reloaded.nil? or @reloaded == false
      true
    else
      false
    end
  end
  def self.reloaded(r = true)
    @reloaded = r
  end
end

# ActiveSupport::Dependencies.log_activity = true
ActiveSupport::Dependencies.unloadable(ModelReloadChecker)
