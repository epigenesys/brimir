require("rails_helper")
RSpec.describe(TicketMailer, :type => :mailer) do
  def receive_email(content)
    ActiveSupport::Deprecation.silence do
      TicketMailer.receive(content)
    end
  end

  let!(:brimir_email_address) { FactoryBot.create(:brimir_email) }
  let(:simple_email) { file_fixture("ticket_mailer/simple").read }

  let(:agent) { FactoryBot.create(:user, :with_agent) }

  it("fixtures are loading correctly") do
    expect(simple_email).to(match(/From:/))
  end

  it("new email from unkown user is stored correctly") do
    expect do
      expect { receive_email(simple_email) }.to(change { User.count })
    end.to(change { Ticket.count })

    expect(Ticket.order(:id).last.to_email_address).to eq brimir_email_address
  end

  it("email threads are recognized correctly and assignee is notified") do
    Tenant.delete_all
    Tenant.current_domain = 'support.host'
    thread_start = file_fixture("ticket_mailer/thread_start").read
    thread_reply = file_fixture("ticket_mailer/thread_reply").read

    expect do
      expect do
        ticket = receive_email(thread_start)
        ticket.assignee = agent
        (ticket.notified_users << agent)
        ticket.save!
      end.to(change { User.count })
    end.to(change { Ticket.count })
    expect do
      expect do
        expect do
          reply = receive_email(thread_reply)
          NotificationMailer.incoming_message(reply, "")
        end.to(change { User.count }.by(0))
      end.to(change { Reply.count })
    end.to(change { ActionMailer::Base.deliveries.size })
  end

  it("email with attachments work") do
    attachments = file_fixture("ticket_mailer/attachments").read
    expect do
      expect { receive_email(attachments) }.to(change { Attachment.count }.by(2))
    end.to(change { Ticket.count })
  end

  it("email with unkown reply_to") do
    unknown_reply_to = file_fixture("ticket_mailer/unknown_reply_to").read
    expect { receive_email(unknown_reply_to) }.to(change { Ticket.count })
  end

  it("email with capitalized from address") do
    capitalized = file_fixture("ticket_mailer/capitalized").read
    expect do
      receive_email(capitalized)
      receive_email(capitalized)
    end.to(change { Ticket.count }.by(2))
  end

  it("should verify email address") do
    unverified_address = FactoryBot.create(:email_address)
    unverified_address.update(verification_token: 'qeECnGA3DO7djolZ')
    verification = file_fixture("ticket_mailer/verification").read
    expect { receive_email(verification) }.to(change { EmailAddress.where(:verification_token => nil).count })
  end

  it("reply to is used for incoming mail") do
    email = file_fixture("ticket_mailer/reply_to").read
    expect { expect { receive_email(email) }.to(change { User.count }) }.to(change { Ticket.count })
    expect(User.last.email).to(eq("reply@address.com"))
  end
end
