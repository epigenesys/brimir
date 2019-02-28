# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  active                 :boolean          default(TRUE), not null
#  agent                  :boolean          default(FALSE), not null
#  authentication_token   :string
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  include_quote_in_reply :boolean          default(TRUE), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locale                 :string
#  name                   :string
#  notify                 :boolean          default(TRUE)
#  per_page               :integer          default(30), not null
#  prefer_plain_text      :boolean          default(FALSE), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  schedule_enabled       :boolean          default(FALSE)
#  sign_in_count          :integer          default(0)
#  signature              :text
#  time_zone              :string
#  created_at             :datetime
#  updated_at             :datetime
#  schedule_id            :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_schedule_id           (schedule_id)
#

FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "alice#{i}@xxxx.com" }
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
