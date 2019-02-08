FactoryBot.define do
  factory :reply do
    ticket { nil }
    content { 'My first text reply' }
    user { nil }
    message_id { 'reply123@reply123' }
  end
end