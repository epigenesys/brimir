require("rails_helper")
RSpec.describe(TicketMailer, :type => :mailer) do
  let!(:brimir_email_address) { FactoryBot.create(:brimir_email) }
  let(:simple_email) { read_fixture("simple").join }

  let(:agent) { FactoryBot.create(:user, :with_agent) }

  it("fixtures are loading correctly") do
    expect(simple_email).to(match(/From:/))
  end

  it("new email from unkown user is stored correctly") do
    expect do
      expect { TicketMailer.receive(simple_email) }.to(change { User.count })
    end.to(change { Ticket.count })

    expect(Ticket.order(:id).last.to_email_address).to eq brimir_email_address
  end

  it("email threads are recognized correctly and assignee is notified") do
    Tenant.current_domain = 'support.host'
    thread_start = read_fixture("thread_start").join
    thread_reply = read_fixture("thread_reply").join

    expect do
      expect do
        ticket = TicketMailer.receive(thread_start)
        ticket.assignee = agent
        (ticket.notified_users << agent)
        ticket.save!
      end.to(change { User.count })
    end.to(change { Ticket.count })
    expect do
      expect do
        expect do
          reply = TicketMailer.receive(thread_reply)
          NotificationMailer.incoming_message(reply, "")
        end.to(change { User.count }.by(0))
      end.to(change { Reply.count })
    end.to(change { ActionMailer::Base.deliveries.size })
  end

  it("email with attachments work") do
    attachments = read_fixture("attachments").join
    expect do
      expect { TicketMailer.receive(attachments) }.to(change { Attachment.count }.by(2))
    end.to(change { Ticket.count })
  end

  it("email with unkown reply_to") do
    unknown_reply_to = read_fixture("unknown_reply_to").join
    expect { TicketMailer.receive(unknown_reply_to) }.to(change { Ticket.count })
  end

  it("email with capitalized from address") do
    capitalized = read_fixture("capitalized").join
    expect do
      TicketMailer.receive(capitalized)
      TicketMailer.receive(capitalized)
    end.to(change { Ticket.count }.by(2))
  end

  it("should verify email address") do
    unverified_address = FactoryBot.create(:email_address)
    unverified_address.update(verification_token: 'qeECnGA3DO7djolZ')
    verification = read_fixture("verification").join
    expect { TicketMailer.receive(verification) }.to(change { EmailAddress.where(:verification_token => nil).count })
  end

  it("reply to is used for incoming mail") do
    email = read_fixture("reply_to").join
    expect { expect { TicketMailer.receive(email) }.to(change { User.count }) }.to(change { Ticket.count })
    expect(User.last.email).to(eq("reply@address.com"))
  end
end
