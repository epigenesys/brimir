require("rails_helper")

describe(Tickets::DeletedController) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:ticket) { FactoryBot.create(:ticket, :with_to_email_address, user: bob, assignee: alice) }
  let!(:ticket2) { FactoryBot.create(:ticket, user: bob, assignee: alice) }
  let!(:ticket3) { FactoryBot.create(:ticket, user: bob, assignee: alice) }

  before { sign_in(alice) }

  it("should empty trash") do
    Ticket.update_all(:status => Ticket.statuses[:deleted])

    expect do
      delete(:destroy)
    end.to(change { Ticket.count }.by(-3))

    expect(response).to redirect_to(tickets_path(:status => :deleted))
  end
end