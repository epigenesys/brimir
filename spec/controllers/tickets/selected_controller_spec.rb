require("rails_helper")

describe(Tickets::SelectedController) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:ticket) { FactoryBot.create(:ticket, :with_to_email_address, user: bob, assignee: alice) }
  let!(:ticket2) { FactoryBot.create(:ticket, user: bob, assignee: alice) }
  let!(:ticket3) { FactoryBot.create(:ticket, user: bob, assignee: alice, status: :closed) }

  before { sign_in(alice) }

  it("should update selected ticket status") do
    request.env["HTTP_REFERER"] = tickets_path
    expect(Ticket.open.count).to(eq(2))

    expect do
      patch(:update, params: { id: Ticket.open.pluck(:id), ticket: ({ :status => "closed" }) })
    end.to(change { Ticket.closed.count }.by(2))

    expect(Ticket.open.count).to(eq(0))
  end

  it("should not give error when id is missing") do
    request.env["HTTP_REFERER"] = tickets_path
    patch(:update)
    expect(response).to redirect_to(tickets_path)
  end
end