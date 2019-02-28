# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  notifiable_type :string
#  created_at      :datetime
#  updated_at      :datetime
#  notifiable_id   :integer
#  user_id         :integer
#
# Indexes
#
#  index_notifications_on_notifiable_type_and_notifiable_id  (notifiable_type,notifiable_id)
#  index_notifications_on_user_id                            (user_id)
#  unique_notification                                       (notifiable_id,notifiable_type,user_id) UNIQUE
#

FactoryBot.define do
  factory :notification do
    user
  end
end
