FactoryBot.define do
  factory :user do
    email { 'alice@xxxx.com' }
    signature { 'Greets, Alice' }
    notify { false }
    authentication_token { 'blabla' }
    association :schedule, factory: :schedule
    current_sign_in_at { Time.now.to_s }

    trait :with_agent do
      agent { true }
    end
  end
end
