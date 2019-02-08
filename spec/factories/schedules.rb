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
end


