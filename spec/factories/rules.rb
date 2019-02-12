FactoryBot.define do
  factory :rule do
    filter_field { 'from' }
    filter_operation { 0 }
    filter_value { '@ivaldi.nl' }
    action_operation { 0 }
    action_value { 'ivaldi' }
  end
end