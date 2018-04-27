RSpec::Matchers.define :be_bson_id do
  match do |actual|
    BSON::ObjectId.legal?(actual)
  end

  failure_message_for_should do |actual|
    "expected #{actual} to be a legal BSON ID"
  end
end
