# == Schema Information
#
# Table name: email_addresses
#
#  id                 :integer          not null, primary key
#  default            :boolean          default(FALSE)
#  email              :string
#  name               :string
#  verification_token :string
#  created_at         :datetime
#  updated_at         :datetime
#

FactoryBot.define do
  factory :email_address do
    sequence(:email) { |i| "outgoing#{i}@support.bla" }

    trait :with_default do
      default { true }
    end

    trait :verified do
      after(:create) { |email_address| email_address.update(verification_token: nil) }
    end

    factory :brimir_email do
      verified
      email { 'brimir@xxxx.com' }
      verification_token { nil }
    end
  end
end
