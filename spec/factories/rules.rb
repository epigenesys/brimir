# == Schema Information
#
# Table name: rules
#
#  id               :integer          not null, primary key
#  action_operation :integer          default("assign_label"), not null
#  action_value     :string
#  filter_field     :string
#  filter_operation :integer          default("contains"), not null
#  filter_value     :string
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryBot.define do
  factory :rule do
    filter_field { 'from' }
    filter_operation { 0 }
    filter_value { '@ivaldi.nl' }
    action_operation { 0 }
    action_value { 'ivaldi' }
  end
end
