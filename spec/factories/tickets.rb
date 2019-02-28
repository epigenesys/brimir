# == Schema Information
#
# Table name: tickets
#
#  id                       :integer          not null, primary key
#  content                  :text(1073741823)
#  content_type             :string           default("html")
#  locked_at                :datetime
#  orig_cc                  :string
#  orig_to                  :string
#  priority                 :integer          default("unknown"), not null
#  raw_message_content_type :string
#  raw_message_file_name    :string
#  raw_message_file_size    :bigint(8)
#  raw_message_updated_at   :datetime
#  status                   :integer          default("open"), not null
#  subject                  :string
#  created_at               :datetime
#  updated_at               :datetime
#  assignee_id              :integer
#  locked_by_id             :integer
#  message_id               :string
#  to_email_address_id      :integer
#  user_id                  :integer
#
# Indexes
#
#  index_tickets_on_assignee_id          (assignee_id)
#  index_tickets_on_locked_by_id         (locked_by_id)
#  index_tickets_on_message_id           (message_id)
#  index_tickets_on_priority             (priority)
#  index_tickets_on_status               (status)
#  index_tickets_on_to_email_address_id  (to_email_address_id)
#  index_tickets_on_user_id              (user_id)
#

FactoryBot.define do
  factory :ticket do
    subject { "I have a problem" }
    content { "My computer doesn't start anymore" }
    association :user, factory: :user
    association :assignee, factory: :user
    priority { :low }
    message_id { 'test123@test123' }

    trait :with_to_email_address do
      association :to_email_address, factory: :email_address, name: 'Brimir'
    end
  end
end
