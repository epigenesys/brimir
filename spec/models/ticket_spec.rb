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
RSpec.describe(Ticket, :type => :model) do
  let!(:dave) { FactoryBot.create(:user, name: 'Dave', email: 'dave@xxxx.com', current_sign_in_at: Time.zone.now) }
  let!(:label) { FactoryBot.create(:label, name: 'bug') }
  let!(:ticket) { FactoryBot.create(:ticket, labels: [label]) }
  let!(:daves_label) { FactoryBot.create(:labeling, label: label, labelable: dave) }
  let!(:daves_ticket) { FactoryBot.create(:ticket, user: dave, subject: "Dave has a problem %@#_", assignee: nil) }

  after { Timecop.return }
  it("should return accessible tickets for customer") do
    tickets = Ticket.viewable_by(dave)
    expect(tickets.count).to(eq(2))
    tickets.each do |ticket|
      expect(((dave == ticket.user) or ((ticket.label_ids & dave.label_ids).size > 0))).to(be_truthy)
    end
  end
  it("should store status changes") do
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

  describe '.search' do
    it("should escape special char search") do
      expect(Ticket.search("%").count).to(eq(1))
      expect(Ticket.search("_").count).to(eq(1))
    end

    context 'with tickets in the system' do
      let!(:alice)              { FactoryBot.create(:user, name: 'Alice', email: 'alice@xxxx.com', current_sign_in_at: Time.zone.now) }
      let!(:subject_ticket)     { FactoryBot.create(:ticket, user: dave, subject: "A unique subject", assignee: nil) }
      let!(:content_ticket)     { FactoryBot.create(:ticket, user: dave, subject: "A subject", content: 'Some unique content', assignee: nil) }
      let!(:searching_by_email) { FactoryBot.create(:ticket, user: alice, subject: "A subject", content: 'Some content', assignee: nil) }

      it 'searches by the tickets subject' do
        expect(Ticket.search('A unique subject')).to eq([subject_ticket])
      end

      it 'searches by the tickets content' do
        expect(Ticket.search('Some unique content')).to eq([content_ticket])
      end

      it 'searches by the tickets user email' do
        expect(Ticket.search('alice@xxxx.com')).to eq([searching_by_email])
      end

      it 'returns an empty collection if there are no matches' do
        expect(Ticket.search('Something not in the system')).to eq([])
      end
    end
  end
end
