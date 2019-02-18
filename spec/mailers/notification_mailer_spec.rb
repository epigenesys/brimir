require("rails_helper")
RSpec.describe(NotificationMailer, :type => :mailer) do
  let(:tenant) { FactoryBot.create(:tenant) }
  let!(:brimir_email_address) { FactoryBot.create(:email_address) }
  let!(:agent)  { FactoryBot.create(:user, :with_agent) }
  let!(:ticket) { FactoryBot.create(:ticket, to_email_address: brimir_email_address) }

  let(:reply) { FactoryBot.create(:reply, content: 'My first text reply', ticket: ticket) }

  before { Tenant.current_domain = tenant.domain }

  it("should notify assignee of new ticket") do
    expect do
      NotificationMailer.new_ticket(ticket, User.agents.first).deliver_now
    end.to(change { ActionMailer::Base.deliveries.size })
    mail = ActionMailer::Base.deliveries.last
    expect(mail["Message-ID"].to_s).to(eq("<#{ticket.message_id}>"))
    expect(mail["From"].to_s).to(eq(brimir_email_address.formatted))
    expect(mail["Return-Path"].to_s).to(eq("support@test.host"))
  end

  it("should notify user of new reply") do
    expect { NotificationMailer.new_reply(reply, agent).deliver_now }.to(change { ActionMailer::Base.deliveries.size })
    mail = ActionMailer::Base.deliveries.last
    expect(mail["In-Reply-To"].to_s).to(eq("<#{reply.ticket.message_id}>"))
    expect(mail["Message-ID"].to_s).to(eq("<#{reply.message_id}>"))
    expect(mail["From"].to_s).to(eq(brimir_email_address.formatted))
    expect(mail["Return-Path"].to_s).to(eq("support@test.host"))
  end


  context 'New user' do
    let(:new_user)         { FactoryBot.create(:user) }
    let(:welcome_template) { FactoryBot.create(:active_user_welcome) }

    it("should notify user of account creation") do
      tenant.notify_user_when_account_is_created = true
      expect { NotificationMailer.new_account(new_user, welcome_template, tenant).deliver_now }.to(change { ActionMailer::Base.deliveries.size })
    end

    it("should not notify user of account creation") do
      tenant.notify_user_when_account_is_created = false
      expect { NotificationMailer.new_account(new_user, welcome_template, tenant).deliver_now }.to_not(change { ActionMailer::Base.deliveries.size })

      tenant.notify_user_when_account_is_created = true
      welcome_template.draft = true
      expect { NotificationMailer.new_account(new_user, welcome_template, tenant).deliver_now }.to_not(change { ActionMailer::Base.deliveries.size })
    end

  end

  it("should not notify our own outgoing addresses") do
    expect do
      NotificationMailer.new_reply(reply, User.new(:email => FactoryBot.create(:email_address).email)).deliver_now
    end.to_not(change { ActionMailer::Base.deliveries.size })
  end


  it("should notify agents of new ticket") do
    daves_ticket = FactoryBot.create(:ticket, assignee: nil, notifications: [FactoryBot.build(:notification), FactoryBot.build(:notification)])

    expect { NotificationMailer.incoming_message(daves_ticket, daves_ticket) }.to(change { ActionMailer::Base.deliveries.size }.by(2))
    first = (ActionMailer::Base.deliveries.count - 2)
    last = (ActionMailer::Base.deliveries.count - 1)
    while (last >= first) do
      mail = ActionMailer::Base.deliveries[last]
      expect(mail["Message-ID"].to_s).to(eq("<#{daves_ticket.message_id}>"))
      last = (last - 1)
    end
  end

  it("should notify agents of new reply") do
    label = FactoryBot.create(:label, name: 'bug')
    label.labelings.create(labelable: FactoryBot.create(:user))
    ticket.labels = [label]


    expect { NotificationMailer.incoming_message(reply, ticket) }.to(change { ActionMailer::Base.deliveries.size }.by(2))
    first = (ActionMailer::Base.deliveries.count - 2)
    last = (ActionMailer::Base.deliveries.count - 1)
    while (last >= first) do
      mail = ActionMailer::Base.deliveries[last]
      expect(mail["Message-ID"].to_s).to(eq("<#{reply.message_id}>"))
      last = (last - 1)
    end
  end
end
