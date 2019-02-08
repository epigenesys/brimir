FactoryBot.define do
  factory :ticket do
    subject { "I have a problem" }
    content { "My computer doesn't start anymore" }
    association :user, factory: :user, email: 'user@xxxx.com'
    association :assignee, factory: :user, email: 'asignee@xxxx.com'
    priority { :low }
    message_id { 'test123@test123' }
    
    trait :with_to_email_address do
      association :to_email_address, factory: :email_address, name: 'Brimir'
    end
  end
end
