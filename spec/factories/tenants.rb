FactoryBot.define do
  factory :tenant do
    domain { 'test.host' }
    from { 'support@test.host' }
  end
end