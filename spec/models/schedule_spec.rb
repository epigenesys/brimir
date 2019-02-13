require("rails_helper")
RSpec.describe(Schedule, :type => :model) do
  it("should parse and write start") do
    schedule = schedules(:empty)
    expect(schedule.start).to(be_nil)
    schedule.start = "08:00"
    schedule.save!
    schedule.reload
    expect(Time.find_zone("UTC").parse("08:00")).to(eq(schedule.start))
    expect(8).to(eq(schedule.start.hour))
  end
  it("should parse and write end") do
    schedule = schedules(:empty)
    expect(schedule.end).to(be_nil)
    schedule.end = "18:00"
    schedule.save!
    schedule.reload
    expect(Time.find_zone("UTC").parse("18:00")).to(eq(schedule.end))
    expect(18).to(eq(schedule.end.hour))
  end
end
