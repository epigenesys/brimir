# == Schema Information
#
# Table name: replies
#
#  id                       :integer          not null, primary key
#  content                  :text(1073741823)
#  content_type             :string           default("html")
#  draft                    :boolean          default(FALSE), not null
#  internal                 :boolean          default(FALSE), not null
#  raw_message_content_type :string
#  raw_message_file_name    :string
#  raw_message_file_size    :bigint(8)
#  raw_message_updated_at   :datetime
#  type                     :string
#  created_at               :datetime
#  updated_at               :datetime
#  message_id               :string
#  ticket_id                :integer
#  user_id                  :integer
#
# Indexes
#
#  index_replies_on_message_id  (message_id)
#  index_replies_on_ticket_id   (ticket_id)
#  index_replies_on_user_id     (user_id)
#

FactoryBot.define do
  factory :reply do
    ticket
    sequence(:content) { |n| "This is reply #{n}" }
    user
    message_id { 'reply123@reply123' }
  end
end
