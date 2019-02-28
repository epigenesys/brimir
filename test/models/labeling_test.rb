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

require 'test_helper'

class LabelingTest < ActiveSupport::TestCase

  test 'should create label for new name' do

    assert_difference 'Label.count' do
      labeling = Labeling.new(
          label: {
              name: 'New label'
          },
          labelable: Ticket.first
      )

      assert_not_nil labeling.label
      assert_equal 'New label', labeling.label.name
    end

  end

  test 'should not create label for existing name' do

    assert_no_difference 'Label.count' do
      labeling = Labeling.new(
          label: {
              name: labels(:bug).name
          },
          labelable: Ticket.first
      )

      assert_not_nil labeling.label
      assert_equal labels(:bug).name, labeling.label.name
    end

  end

end
