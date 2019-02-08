FactoryBot.define do
  factory :labeling do
    association :label, factory: :label
    labelable { nil}
  end
end