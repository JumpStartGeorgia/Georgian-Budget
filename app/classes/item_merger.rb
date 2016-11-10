class ItemMerger
  def initialize(receiver)
    @receiver = receiver
  end

  def merge(giver)
    unless receiver.class == giver.class
      raise "Merging #{giver.class} into #{receiver.class} is not allowed; types must be the same"
    end

    merge_codes(giver.codes)

    giver.destroy
  end

  private

  attr_reader :receiver

  def merge_codes(codes)
    codes.each do |code|
      receiver.take_code(code)
    end
  end
end
