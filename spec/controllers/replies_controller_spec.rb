require("rails_helper")
RSpec.describe(RepliesController, :type => :controller) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:dave) { FactoryBot.create(:user, name: 'Dave', email: 'dave@xxxx.com', current_sign_in_at: Time.zone.now) }
  let!(:label) { FactoryBot.create(:label, name: 'bug') }
  let!(:ticket) { FactoryBot.create(:ticket, user: bob, assignee: alice, labels: [label]) }
  let!(:reply) { FactoryBot.create(:reply, ticket: ticket, user: bob) }
  let!(:daves_label) { FactoryBot.create(:labeling, label: label, labelable: dave) }

  before do
    sign_in(alice)
  end

  it("reply should always contain text") do
    expect do
      expect do
        post(:create, :params => ({ :reply => ({ :content => "", :ticket_id => ticket.id, :notified_user_ids => ([bob.id]) }) }))
        assert_response(:success)
      end.to_not(change { Reply.count })
    end.to_not(change { ActionMailer::Base.deliveries.size })
  end

  it("should send correct reply notification mail") do
    post(:create, :params => ({ :reply => ({ :content => "<br><br><p><strong>this is in bold</strong></p>", :ticket_id => ticket.id, :notified_user_ids => User.agents.pluck(:id) }) }))
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.html_part.body.decoded).to(match("<br><br><p><strong>this is in bold</strong></p>"))
    expect(mail.text_part.body.decoded).to(match("\n\nthis is in bold\n"))
    expect(mail.to).to(eq([User.agents.last.email]))
    expect(mail.content_type).to(match("multipart/alternative"))
    expect(mail.text_part.body.decoded).to(match(I18n.translate(:view_reply)))
    expect(assigns(:reply).message_id).to_not(be_nil)
  end

  it("reply should have attachments") do
    expect do
      post(:create, :params => ({ :reply => ({ :content => "**this is in bold**", :ticket_id => ticket.id, :notified_user_ids => ([bob.id]), :attachments_attributes => ({ :"0" => ({ :file => fixture_file_upload(Rails.root.join('spec', 'fixtures', 'ticket_mailer', 'simple')) }), :"1" => ({ :file => fixture_file_upload(Rails.root.join('spec', 'fixtures', 'ticket_mailer', 'simple')) }) }) }) }))
    end.to(change { Attachment.count }.by(2))
  end

  it("should be able to respond to others ticket as customer if I have access to the label") do
    sign_out(alice)
    sign_in(dave)

    post(:create, :params => ({ :reply => ({ :content => "test", :ticket_id => ticket.id, :notified_user_ids => ([bob.id, alice.id]) }) }))

    expect(ActionMailer::Base.deliveries.size).to eq(2)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.smtp_envelope_to).to(eq([alice.email]))
  end

  it("should re-open ticket") do
    ticket.status = "closed"
    ticket.save
    post(:create, :params => ({ :reply => ({ :content => "re-open please", :ticket_id => ticket.id }) }))
    ticket.reload
    expect(ticket.status).to(eq("open"))
  end

  it("should get raw message") do
    
    reply.raw_message = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'ticket_mailer', 'simple'))
    reply.save!
    reply.reload
    get(:show, :params => ({ :id => reply.id, :format => :eml }))
    assert_response(:success)
  end
end
