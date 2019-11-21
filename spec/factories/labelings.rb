# == Schema Information
#
# Table name: labelings
#
#  id             :integer          not null, primary key
#  labelable_type :string
#  created_at     :datetime
#  updated_at     :datetime
#  label_id       :integer
#  labelable_id   :integer
#
# Indexes
#
#  index_labelings_on_label_id                         (label_id)
#  index_labelings_on_labelable_type_and_labelable_id  (labelable_type,labelable_id)
#  unique_labeling_label                               (label_id,labelable_id,labelable_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (label_id => labels.id)
#

FactoryBot.define do
  factory :labeling do
    association :label, factory: :label
    labelable { nil}
  end
end
