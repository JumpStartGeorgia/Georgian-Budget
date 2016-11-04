class TimePrettifier
  def prettify(time = 0)
    Time.at(time).utc.strftime("%H:%M:%S").to_s
  end

  def run
    @elapsed = nil
    start_time = Time.now
    yield
    @elapsed = Time.now - start_time
  end

  def elapsed_prettified
    prettify(elapsed)
  end

  attr_reader :elapsed
end
