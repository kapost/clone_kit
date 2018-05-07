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
        CloneKit::Rules::Remap.new("BlogPost", "Account" => "account_id", "BlogType" => "blog_type_id")
      ]
    )
    spec.after_operation do |operation|
      ...
    end
end
```

## Writing an Emitter

By default, CloneKit specifications utilize an empty emitter, making all clones no-ops. Emitters are expected to make db calls using logic defined in the emitter.

#### Emitter rules
  - Emitters must respond to `#emit_all` and `#scope`.
  - `emit_all` must return an object that responds to `#pluck`.

```ruby
CloneKit::ActiveRecordSpecification.new(BlogPost) do |spec|
  ...
  spec.emitter = ActiveRecordEmitter.new(BlogPost)
  ...
end

class ActiveRecordEmitter
  def initialize(klass)
    self.klass = klass
  end

  def scope(*)
    klass.all # add any scope restrictions here
  end

  def emit_all # the method that will be used to pluck the record ids
    scope
  end

  private

  attr_accessor :klass
end
```

## Custom Cloners

Cloners are the classes that determine what model class is cloned and how. There are several built-in cloners that can be extended. See `lib/clone_kit/cloners` for a list.

Custom cloners will need to define:

1. The Mongoid or ActiveRecord model class, which will be used to make db calls
2. Rules, which are executed in the defined order and determine how the ids are mapped from source to destination records. See more in next section.
3. Merge fields, which allow two records to be merged into one provided all listed fields are equal.

Optionally, if you are merging records you will probably want to override the `compare` and `merge` methods with custom logic, though basic logic comes for free.

```ruby
CloneKit::ActiveRecordSpecification.new(self) do |spec|
  ...
  spec.cloner = BlogPostCloner.new
  ...
end

class BlogPostCloner < ActiveRecordRulesetCloner
  OMIT_ATTRIBUTES = [:created_at, :updated_at]

  def initialize
    super(
      BlogPost,                                           # model class
      rules: [                                            # rules
        CloneKit::Rules::Except.new(*OMIT_ATTRIBUTES),
        CloneKit::Rules::Remap.new(BlogPost)
      ],
      merge_fields: [])                                   # merge fields
  end

  def compare(first, second)
    # returns a boolean to determine if two records are mergeable
  end

  def merge(records)
    # returns a single record that is the merged result
    # of all argument `records`,
    # e.g. [{ a: 1, b: 1 }, { a: 2, b: 1}] => { a: 2, b: 1 }
  end
end

```

## Writing a Cloner rule

Rules respond to a single `#fix` method. TODO - more thorough description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clone_kit'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install clone_kit
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kapost/clone_kit.
