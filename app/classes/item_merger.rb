class ItemMerger
  def initialize(receiver)
    @receiver = receiver
  end

  def merge(giver)
    unless receiver.class == giver.class
      raise "Merging #{giver.class} into #{receiver.class} is not allowed; types must be the same"
    end

    merge_priority(giver.priority)
    merge_codes(giver.codes)
    merge_names(giver.names)

    giver.destroy
  end

  private

  attr_reader :receiver

  def merge_priority(new_priority)
    return if new_priority.nil?

    if receiver.priority == nil
      receiver.priority = new_priority
      receiver.save!
    else
      raise 'Cannot merge object with different priority' if receiver.priority != new_priority
    end
  end

  def merge_codes(new_codes)
    new_codes.each do |new_code|
      receiver.take_code(new_code)
    end
  end

  def merge_names(new_names)
    new_names.each do |new_name|
      receiver.take_name(new_name)
    end
  end
end
