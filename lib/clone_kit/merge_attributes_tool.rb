# frozen_string_literal: true

module CloneKit
  # Given an array of hashes representing records, this class is able to resolve
  # values among them using a variety of strategies. The strategies all merge right-to-left,
  # meaning that the last record is given precidence over the first.
  #
  # hashes
  #   assigns to a target hash a list of hash attributes that are (deeply)
  #   from the others
  #
  # arrays
  #   assigns to a target hash a list of array attributes that are concatenated
  #   and uniquified from the others
  #
  # cluster
  #   assigns to a target hash a list of attributes that are copied from the first
  #   record that returns true using the given block
  #
  # last
  #   assigns to a target hash a list of attributes that are copied from the
  #   last record
  #
  # any
  #   assigns to a target hash a list of attributes from any other record where
  #   that attribute is not blank.
  #
  # max/min
  #   assigns to a target hash the maximum/minimum value from other records for each
  #   from a list of attribute
  #
  class MergeAttributesTool
    def initialize(mergeable)
      self.mergeable = mergeable
    end

    def hashes(target, *attributes)
      attributes.each do |att|
        result = {}
        mergeable.each do |m|
          result = result.deep_merge(m[att])
        end
        target[att] = result
      end
    end

    def arrays(target, *attributes)
      attributes.each do |att|
        new_val = mergeable.flat_map { |m| m[att] }.uniq
        target[att] = new_val
      end
    end

    def cluster(target, *attributes)
      mergeable.reverse_each do |m|
        next unless yield m

        attributes.each do |att|
          target[att] = m[att]
        end
        break
      end
    end

    def last(target, *attributes)
      attributes.each do |att|
        target[att] = mergeable[-1][att]
      end
    end

    def any(target, *attributes)
      attributes.each do |att|
        mergeable.reverse_each do |m|
          val = m[att]
          unless val.blank?
            target[att] = val
            break
          end
        end
      end
    end

    def max(target, *attributes)
      attributes.each do |att|
        target[att] = mergeable.map { |m| m[att] }.compact.max
      end
    end

    def min(target, *attributes)
      attributes.each do |att|
        target[att] = mergeable.map { |m| m[att] }.compact.min
      end
    end

    private

    attr_accessor :mergeable
  end
end
