# frozen_string_literal: true

# ENV["RAILS_ENV"] ||= "test"
# require File.expand_path("spec/dummy_app/config/environment")

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "clone_kit"
require "combustion"
require "mongoid"
require "active_record"
require "pg"
require "pry"
require "rspec/collection_matchers"
require "fakeredis/rspec"
require "database_cleaner"
require 'simplecov'
SimpleCov.start

ENV["MONGOID_ENV"] = "test"
Mongoid.load!("#{File.dirname(__FILE__)}/config/mongoid.yml")

Combustion.initialize! :active_record

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:active_record].strategy = :truncation
  end

  config.before(:all) do
    DatabaseCleaner[:mongoid].clean
    DatabaseCleaner[:active_record].clean
  end

  config.before :example do |_example|
    DatabaseCleaner[:mongoid].start
    DatabaseCleaner[:active_record].start
    CloneKit.reset_graph!
  end

  config.after :example do |_example|
    DatabaseCleaner[:mongoid].clean
    DatabaseCleaner[:active_record].clean
  end
end
