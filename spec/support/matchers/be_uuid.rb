RSpec::Matchers.define :be_uuid do
  match do |actual|
    actual.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89AB][0-9a-f]{3}-[0-9a-f]{12}$/i)
  end

  failure_message_for_should do |actual|
    "expected #{actual} to be a legal UUID"
  end
end
