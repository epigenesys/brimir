require("rails_helper")

describe Reply, :type => :model do
  let!(:tenant) { FactoryBot.create(:tenant) }
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:charlie) { FactoryBot.create(:user, :with_agent, name: 'Charlie', email: 'charlie@xxxx.com', schedule_enabled: false, notify: true) }
  let!(:dave) { FactoryBot.create(:user, name: 'Dave', email: 'dave@xxxx.com', current_sign_in_at: Time.zone.now) }
  let!(:label) { FactoryBot.create(:label, name: 'bug') }
  let!(:ticket) { FactoryBot.create(:ticket, user: bob, assignee: alice, labels: [label]) }
  let!(:daves_label) { FactoryBot.create(:labeling, label: label, labelable: dave) }
  let!(:daves_ticket) { FactoryBot.create(:ticket, user: dave, assignee: nil, notifications: [FactoryBot.build(:notification, user: bob), FactoryBot.build(:notification, user: charlie)]) }

  before { Tenant.current_domain = tenant.domain }

  it("should notify label users") do
    ticket = Ticket.new(:from => "test@test.com", :content => "test")
    (ticket.labels << label)
    reply = ticket.replies.new
    reply.set_default_notifications!
    expect(reply.notified_users.include?(dave)).to(eq(true))
  end

  it("should reply to all agents if not assigned") do
    Tenant.current_tenant.first_reply_ignores_notified_agents = true
    reply = daves_ticket.replies.new
    reply.set_default_notifications!
    expect(reply.notified_users.include?(alice)).to(eq(true))
    expect(reply.notified_users.include?(charlie)).to(eq(true))
  end

  it("should not reply to all agents if assigned") do
    Tenant.current_tenant.first_reply_ignores_notified_agents = true
    daves_ticket.assignee = alice
    daves_ticket.save
    reply = daves_ticket.replies.new
    reply.user = alice
    reply.reply_to = daves_ticket
    reply.set_default_notifications!
    expect(reply.notified_users.include?(alice)).to(eq(false))
    expect(reply.notified_users.include?(charlie)).to(eq(false))
    expect(reply.notified_users.include?(dave)).to(eq(true))
    expect(reply.notified_users.include?(bob)).to(eq(true))
  end

  it("should reply to agent if assigned") do
    Tenant.current_tenant.first_reply_ignores_notified_agents = false
    daves_ticket.assignee = alice
    daves_ticket.save
    reply = daves_ticket.replies.new
    reply.user = alice
    reply.reply_to = daves_ticket
    reply.set_default_notifications!
    expect(reply.notified_users.include?(alice)).to(eq(false))
    expect(reply.notified_users.include?(charlie)).to(eq(true))
  end

  it("should not notify other clients when one of the clients replies") do
    #
    # Suppose, several clients are part of a conversation. Now, one of the
    # clients replies to something an agent wrote and only answers to the
    # email address of the ticket system, e.g. support@example.com.
    #
    # The other clients that are part of this conversation should not be
    # notified, since the sender can't see that they would receive this
    # email.
    #
    # See also: https://github.com/ivaldi/brimir/issues/259
    #
    agent = User.create!(:email => "agent@example.com", :agent => true)
    client1 = User.create!(:email => "client1@example.com")
    client2 = User.create!(:email => "client2@example.com")

    # client1 creates a ticket via email.
    ticket = Ticket.create(:from => "client1@example.com", :content => "This is my problem")

    # agent replies via the web ui of brimir.
    reply_of_the_agent = ticket.replies.create!(:content => "This might be the solution. It did work for client2 who also works in your office.", :user => agent)
    (reply_of_the_agent.notified_users << client1)
    (reply_of_the_agent.notified_users << client2)

    # client1 replies via email; cc to client2.
    reply_of_client1 = ticket.replies.create!(:content => "It did not work.", :user => client1)
    reply_of_client1.reply_to = reply_of_the_agent
    reply_of_client1.set_default_notifications!("From: client1@example.com\nTo: ...")

    unless reply_of_client1.notified_users.include?(client2) then
      (reply_of_client1.notified_users << client2)
    end

    expect(reply_of_client1.notified_users.include?(agent)).to(eq(true))
    expect(reply_of_client1.notified_users.include?(client2)).to(eq(true))

    # client2 replies via email, but not cc to client1.
    reply_of_client2 = ticket.replies.create!(:content => "client1 is stupid! Did he even start his computer?", :user => client2)
    reply_of_client2.reply_to = reply_of_the_agent
    reply_of_client2.set_default_notifications!("From: client2@example.com\nTo: ...")
    expect(reply_of_client2.notified_users.include?(agent)).to(eq(true))
    expect((not reply_of_client2.notified_users.include?(client1))).to(be_truthy)
  end

  it("should sync the message ids of notifications") do
    ticket = daves_ticket
    reply = ticket.replies.create(:user => alice, :content => "This is the solution.")
    (reply.notified_users << dave)
    (reply.notified_users << bob)
    message_ids = reply.notification_mails.map(&:message_id)
    expect(2).to(eq(message_ids.count))
    expect(1).to(eq(message_ids.uniq.count))
    expect("").to_not(eq(message_ids.first))
    expect(nil).to_not(eq(message_ids.first))
  end
end
