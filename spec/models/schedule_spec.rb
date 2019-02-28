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

require("rails_helper")
RSpec.describe(Schedule, :type => :model) do
  it("should parse and write start") do
    schedule = FactoryBot.create(:empty_schedule)
    expect(schedule.start).to(be_nil)
    schedule.start = "08:00"
    schedule.save!
    schedule.reload
    expect(Time.find_zone("UTC").parse("08:00")).to(eq(schedule.start))
    expect(8).to(eq(schedule.start.hour))
  end
  it("should parse and write end") do
    schedule = FactoryBot.create(:empty_schedule)
    expect(schedule.end).to(be_nil)
    schedule.end = "18:00"
    schedule.save!
    schedule.reload
    expect(Time.find_zone("UTC").parse("18:00")).to(eq(schedule.end))
    expect(18).to(eq(schedule.end.hour))
  end
end
