# frozen_string_literal: true

require "redis"

module CloneKit
  class SharedIdMap
    attr_reader :namespace

    def initialize(namespace, redis: Redis.new)
      self.namespace = namespace
      self.redis = redis
    end

    def lookup(klass, original_id)
      BSON::ObjectId.from_string(redis.hget(hash_key(klass), original_id.to_s))
    rescue BSON::ObjectId::Invalid
      raise ArgumentError, "No mapping found for #{klass}. This usually indicates a dependency has not be specified"
    end

    def lookup_safe(klass, original_id, default = nil)
      val = redis.hget(hash_key(klass), original_id.to_s)
      if val.blank?
        default
      else
        BSON::ObjectId.from_string(val)
      end
    end

    def insert(klass, original_id, new_id)
      redis.hset(hash_key(klass), original_id.to_s, new_id.to_s)
    end

    def insert_many(klass, hash)
      redis.pipelined do
        hash.each do |k, v|
          insert(klass, k, v)
        end
      end
    end

    def mapping(klass)
      Hash[redis.hgetall(hash_key(klass)).map { |k, v| [k, v] }]
    end

    def hash_key(klass)
      klass = klass.name if klass.is_a?(Class)
      "clone_kit_id_map/#{namespace}/#{klass}"
    end

    private

    attr_writer :namespace
    attr_accessor :redis
  end
end
