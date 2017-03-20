# CloneKit!

An ActiveRecord-ish toolkit library for building database record cloning without the business logic and executing cloning operations, especially for multi-tenant applications using Mongoid.

## Why does cloning require a special toolkit?

When operating a multi-tenant system, copying database records is fraught with perils that can wreak havoc on customer integrity. Failing to remap foreign ids does not usually trigger database integrity errors (especially in MongoDB :trollface:) but are even more insidious.

There is likely an alternative business logic required when records are copied and merged. CloneKit can help you assemble that logic.

## How do I clone?

Let's pretend you have a account that you want to clone to a new account.

```ruby
class BlogPost
  include Mongoid::Document

  field :account_id, type: BSON::ObjectId
  field :blog_type_id, type: BSON::ObjectId
  field :body, type: String
end
```

You can specify the dependency order of cloning, the scope of the operation, and the specific cloning behavior inside a specification:

```ruby
CloneKit::Specification.new(BlogPost) do |spec|
spec.dependencies = %w(Account BlogType)                     # Helps derive the cloning order
  spec.emitter = TenantEmitter.new(BlogPost)                 # The scope of the operation for this collection
  spec.cloner = CloneKit::Cloners::MongoidRulesetCloner.new( # The cloning behavior
    BlogPost,
    rules: [
      ReTenantRule.new,
      CloneKit::Rules::Remap.new("Account" => "account_id", "BlogType" => "blog_type_id")
    ]
  )
end
```

## Writing an Emitter

You have to write some emitters for your app. By default, CloneKit specifications utilize and empty emitter, making all clones no-operations.

TODO

## Writing a Cloner

TODO

## Extending the built-in Cloners

TODO

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clone_kit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clone_kit

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/clone_kit.
