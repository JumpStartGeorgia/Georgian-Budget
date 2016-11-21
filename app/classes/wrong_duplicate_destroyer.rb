# destroys possible duplicate pairs that are no longer possible duplicates
# (they were marked as possible duplicates earlier, but new data
# has shown that they cannot be duplicates)

class WrongDuplicateDestroyer
  def destroy_non_duplicate_pairs(pairs)
    pairs.each do |pair|
      next if DuplicateFinder.new(pair.item1).is_possible_duplicate?(pair.item2)
      pair.destroy
    end
  end
end
