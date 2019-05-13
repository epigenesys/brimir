# == Schema Information
#
# Table name: labels
#
#  id         :integer          not null, primary key
#  color      :string
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryBot.define do
  factory :label do
    name { 'label' }
  end
end
