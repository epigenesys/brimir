require("rails_helper")
RSpec.describe(Ticket, :type => :model) do
  after { Timecop.return }
  it("should return accessible tickets for customer") do
    dave = users(:dave)
    tickets = Ticket.viewable_by(dave)
    expect(tickets.count).to(eq(2))
    tickets.each do |ticket|
      expect(((dave == ticket.user) or ((ticket.label_ids & dave.label_ids).size > 0))).to(be_truthy)
    end
  end
  it("should store status changes") do
    ticket = tickets(:problem)
    expect do
      ticket.status = "waiting"
      ticket.save
    end.to(change { StatusChange.count })
    Timecop.travel(Time.now.advance(:hours => 3))
    expect do
      ticket.status = "open"
      ticket.save
    end.to(change { StatusChange.count })
    first = ticket.status_changes.first
    expect(first.updated_at).to_not(eq(first.created_at))
    last = ticket.status_changes.last
    expect(last.updated_at).to(eq(last.created_at))
  end
  it("should escape special char search") do
    expect(Ticket.search("%").count).to(eq(1))
    expect(Ticket.search("_").count).to(eq(1))
  end
end
