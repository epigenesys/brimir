# == Schema Information
#
# Table name: attachments
#
#  id                :integer          not null, primary key
#  attachable_type   :string
#  file_content_type :string
#  file_file_name    :string
#  file_file_size    :bigint(8)
#  file_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  attachable_id     :integer
#  content_id        :string
#
# Indexes
#
#  index_attachments_on_attachable_id  (attachable_id)
#

FactoryBot.define do
  factory :attachment do
    attachable { nil }
  end
end
