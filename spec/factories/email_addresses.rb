FactoryBot.define do
  factory :email_address do
    email { 'outgoing@support.bla' }

    trait :with_default do
      default { true }
    end
  end
end
