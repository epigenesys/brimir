# == Schema Information
#
# Table name: tickets
#
#  id                       :integer          not null, primary key
#  content                  :text(1073741823)
#  content_type             :string           default("html")
#  locked_at                :datetime
#  orig_cc                  :string
#  orig_to                  :string
#  priority                 :integer          default("unknown"), not null
#  raw_message_content_type :string
#  raw_message_file_name    :string
#  raw_message_file_size    :bigint(8)
#  raw_message_updated_at   :datetime
#  status                   :integer          default("open"), not null
#  subject                  :string
#  created_at               :datetime
#  updated_at               :datetime
#  assignee_id              :integer
#  locked_by_id             :integer
#  message_id               :string
#  to_email_address_id      :integer
#  user_id                  :integer
#
# Indexes
#
#  index_tickets_on_assignee_id          (assignee_id)
#  index_tickets_on_locked_by_id         (locked_by_id)
#  index_tickets_on_message_id           (message_id)
#  index_tickets_on_priority             (priority)
#  index_tickets_on_status               (status)
#  index_tickets_on_to_email_address_id  (to_email_address_id)
#  index_tickets_on_user_id              (user_id)
#

require("rails_helper")
RSpec.describe(TicketMerge, :type => :model) do
  let!(:agent_user) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:client_user) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:dave) { FactoryBot.create(:user, name: 'Dave', email: 'dave@xxxx.com', current_sign_in_at: Time.zone.now) }
  let!(:ticket) { FactoryBot.create(:ticket, :with_to_email_address, user: client_user, assignee: agent_user) }
  let!(:ticket_reply) { FactoryBot.create(:reply, ticket: ticket, user: client_user) }
  let!(:daves_ticket) { FactoryBot.create(:ticket, user: dave) }

  it("merging two tickets") do
    first_ticket = Ticket.create(:subject => "First ticket", :content => "I've got a question ...", :user_id => client_user.id)
    Timecop.travel(2.minutes.from_now)
    first_reply = first_ticket.replies.create(:content => "Please send me some more info about ...", :user_id => agent_user.id)
    Timecop.travel(20.minutes.from_now)
    second_ticket = Ticket.create(:subject => "Second ticket", :content => "I forgot to mention ...", :user_id => client_user.id)
    Timecop.travel(1.hour.from_now)
    second_ticket_updated_at_before_merge = second_ticket.updated_at
    separate_tickets = [first_ticket, second_ticket]
    merged_ticket = MergedTicket.from(separate_tickets)
    expect(merged_ticket.replies.count).to(eq(2))
    expect(first_ticket.id).to(eq(merged_ticket.id))
    expect(merged_ticket.replies.pluck(:content).include?("Please send me some more info about ...")).to(eq(true))
    expect(merged_ticket.replies.pluck(:content).include?("I forgot to mention ...")).to(eq(true))
    expect((merged_ticket.replies.order(:created_at).first.user == agent_user)).to(be_truthy)
    expect((merged_ticket.replies.order(:created_at).last.user == client_user)).to(be_truthy)
    expect(second_ticket.created_at.to_i).to(eq(merged_ticket.replies.order(:created_at).last.created_at.to_i))
    expect(second_ticket_updated_at_before_merge.to_i).to(eq(merged_ticket.replies.order(:created_at).last.updated_at.to_i))
  end

  it("merging two tickets and providing an agent who is performing the merge") do
    first_ticket = Ticket.create(:subject => "First ticket", :content => "I've got a question ...", :user_id => client_user.id)
    Timecop.travel(2.minutes.from_now)
    second_ticket = Ticket.create(:subject => "Second ticket", :content => "I forgot to mention ...", :user_id => client_user.id)
    merged_ticket = MergedTicket.from([first_ticket, second_ticket], :current_user => agent_user)
    second_ticket.reload
    expect(merged_ticket.replies.count).to(eq(1))
    expect((second_ticket.replies.last.user == agent_user)).to(be_truthy)
    expect((second_ticket.replies.last.internal == true)).to(be_truthy)
    expect(second_ticket.replies.last.content.include?(first_ticket.id.to_s)).to(eq(true))
    expect((second_ticket.status == "merged")).to(be_truthy)
  end

  it("merging two tickets and copying over the notifications") do
    first_ticket = Ticket.create(:subject => "First ticket", :content => "I've got a question ...", :user_id => client_user.id)
    (first_ticket.notified_users << agent_user)
    Timecop.travel(2.minutes.from_now)
    second_ticket = Ticket.create(:subject => "Second ticket", :content => "I forgot to mention ...", :user_id => client_user.id)
    (second_ticket.notified_users << agent_user)
    Timecop.travel(4.minutes.from_now)
    second_reply = second_ticket.replies.create(:content => "Please send me some more info about ...", :user_id => agent_user.id)
    (second_reply.notified_users << client_user)
    merged_ticket = MergedTicket.from([first_ticket, second_ticket], :current_user => agent_user)
    expect(merged_ticket.notified_users.include?(agent_user)).to(eq(true))
    expect(merged_ticket.replies.order(:created_at).first.notified_users.include?(agent_user)).to(eq(true))
    expect(merged_ticket.replies.order(:created_at).last.notified_users.include?(client_user)).to(eq(true))
  end

  it("merging tickets with attachments") do
    first_ticket = Ticket.create(:subject => "First ticket", :content => "I've got a question ...", :user_id => client_user.id)
    Timecop.travel(2.minutes.from_now)
    first_reply = first_ticket.replies.create(:content => "Please send me some more info about ...", :user_id => agent_user.id)
    Timecop.travel(20.minutes.from_now)
    second_ticket = Ticket.create(:subject => "Second ticket", :content => "I forgot to mention ...", :user_id => client_user.id)
    Timecop.travel(1.hour.from_now)
    first_attachment = first_ticket.attachments.create!
    second_attachment = second_ticket.attachments.create!
    reply_with_attachment = second_ticket.replies.create!(:content => "Reply with attachment")
    reply_attachment = reply_with_attachment.attachments.create!
    separate_tickets = [first_ticket, second_ticket]
    merged_ticket = MergedTicket.from(separate_tickets)
    expect(merged_ticket.attachments.include?(first_attachment)).to(eq(true))
    expect(merged_ticket.replies.collect { |reply| reply.attachments }.flatten.include?(reply_attachment)).to(eq(true))
    expect([second_attachment, reply_attachment].count).to(eq(merged_ticket.replies.collect { |reply| reply.attachments }.flatten.count))
  end

  it("accessing attachment file for merged ticket") do
    ticket1 = ticket
    ticket2 = daves_ticket
    ticket1.attachments.create!(:file => File.open("spec/fixtures/attachments/default-testpage.pdf"))
    ticket2.attachments.create!(:file => File.open("spec/fixtures/attachments/default-testpage.pdf"))
    expect(File.file?(ticket1.attachments.first.file.path(:original))).to(eq(true))
    expect(File.file?(ticket2.attachments.first.file.path(:original))).to(eq(true))
    merged_ticket = MergedTicket.from([ticket1, ticket2])
    expect(ticket1.message_id).to(eq(merged_ticket.message_id))
    expect(ticket2.message_id).to(eq(merged_ticket.replies.last.message_id))
    expect(File.file?(merged_ticket.attachments.first.file.path(:original))).to(eq(true))
    expect(File.file?(merged_ticket.replies.last.attachments.first.file.path(:original))).to(eq(true))
    expect(merged_ticket.attachments.first.file.path(:original)).to(eq(ticket1.attachments.first.file.path(:original)))
    expect(merged_ticket.replies.last.attachments.first.file.path(:original)).to(eq(ticket2.attachments.first.file.path(:original)))
  end

  it("accessing attachment file for merged reply") do
    ticket1 = daves_ticket
    ticket1.update!(:created_at => 1.hour.ago)
    ticket2 = ticket
    ticket2.update!(:created_at => 30.minutes.ago)
    ticket2.replies.first.update!(:created_at => 15.minutes.ago)
    ticket2.replies.first.attachments.create!(:file => File.open("spec/fixtures/attachments/default-testpage.pdf"))
    expect(File.file?(ticket2.replies.first.attachments.first.file.path(:original))).to(eq(true))
    merged_ticket = MergedTicket.from([ticket1, ticket2])
    expect(ticket1.message_id).to(eq(merged_ticket.message_id))
    expect(2).to(eq(merged_ticket.replies.count))
    expect(ticket2.message_id).to(eq(merged_ticket.replies.order(:created_at).first.message_id))
    expect(ticket2.replies.first.message_id).to(eq(merged_ticket.replies.order(:created_at).last.message_id))
    expect(File.file?(merged_ticket.replies.order(:created_at).last.attachments.first.file.path(:original))).to(eq(true))
  end

  it("accessing raw message for merged ticket") do
    ticket1 = ticket
    ticket2 = daves_ticket
    ticket1.update!(:raw_message => File.open("spec/fixtures/attachments/default-testpage.pdf"))
    ticket2.update!(:raw_message => File.open("spec/fixtures/attachments/default-testpage.pdf"))
    expect(File.file?(ticket1.raw_message.path(:original))).to(eq(true))
    expect(File.file?(ticket2.raw_message.path(:original))).to(eq(true))
    merged_ticket = MergedTicket.from([ticket1, ticket2])
    expect(File.file?(merged_ticket.raw_message.path(:original))).to(eq(true))
    expect(File.file?(merged_ticket.replies.last.raw_message.path(:original))).to(eq(true))
  end

  it("accessing raw message for merged reply") do
    ticket1 = daves_ticket
    ticket1.update!(:created_at => 1.hour.ago)
    ticket2 = ticket
    ticket2.update!(:created_at => 30.minutes.ago)
    ticket2.replies.first.update!(:created_at => 15.minutes.ago)
    ticket2.replies.first.update!(:raw_message => File.open("spec/fixtures/attachments/default-testpage.pdf"))
    expect(File.file?(ticket2.replies.first.raw_message.path(:original))).to(eq(true))
    merged_ticket = MergedTicket.from([ticket1, ticket2])
    expect(File.file?(merged_ticket.replies.order(:created_at).last.raw_message.path(:original))).to(eq(true))
  end
end
