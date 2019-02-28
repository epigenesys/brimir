# == Schema Information
#
# Table name: schedules
#
#  id         :integer          not null, primary key
#  end        :datetime
#  friday     :boolean          default(TRUE), not null
#  monday     :boolean          default(TRUE), not null
#  saturday   :boolean          default(FALSE), not null
#  start      :datetime
#  sunday     :boolean          default(FALSE), not null
#  thursday   :boolean          default(TRUE), not null
#  tuesday    :boolean          default(TRUE), not null
#  wednesday  :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :schedule do
    sunday { true }
    monday { true }
    tuesday { true }
    wednesday { true }
    thursday { true }
    friday { true }
    saturday { true }
  end

  factory :part_time_schedule, class: Schedule do
    sunday { false }
    monday { true }
    tuesday { true }
    wednesday { true }
    thursday { false }
    friday { false }
    saturday { false }
  end

  factory :empty_schedule, class: Schedule do
    sunday { false }
    monday { false }
    tuesday { false }
    wednesday { false }
    thursday { false }
    friday { false }
    saturday { false }
  end
end
