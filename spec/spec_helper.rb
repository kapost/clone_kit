# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "clone_kit"
require "mongoid"
require "pry"
require "rspec/collection_matchers"
require "fakeredis/rspec"
require "database_cleaner"

ENV["MONGOID_ENV"] = "test"
Mongoid.load!("#{File.dirname(__FILE__)}/config/mongoid.yml")

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.before(:all) do
    DatabaseCleaner[:mongoid].clean
  end

  config.before :example do |_example|
    DatabaseCleaner[:mongoid].start
  end

  config.after :example do |_example|
    DatabaseCleaner[:mongoid].clean
  end
end
