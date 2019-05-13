require("rails_helper")

describe UsersController do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:ticket) { FactoryBot.create(:ticket, :with_to_email_address, user: bob, assignee: alice) }
  let!(:reply) { FactoryBot.create(:reply, ticket: ticket, user: bob) }
  let!(:bug_label) { FactoryBot.create(:label, name: 'Bug') }

  it("should get index") do
    sign_in(alice)
    get(:index)
    expect(response).to have_http_status(:success)
  end

  it("should not get index") do
    sign_in(bob)
    get(:index)
    expect(response).to have_http_status(:unauthorized)
  end

  it("should get edit") do
    sign_in(alice)
    get(:edit, :params => ({ :id => alice.id }))
    expect(response).to have_http_status(:success)
  end

  it("should modify signature") do
    sign_in(alice)
    put(:update, :params => ({ :id => alice.id, :user => ({ :signature => "Alice" }) }))
    expect(assigns(:user).signature).to(eq("Alice"))
    expect(response).to redirect_to(users_path)
  end

  it("customer may not become agent") do
    sign_in(bob)
    expect {
      put(:update, :params => ({ :id => bob.id, :user => ({ :agent => true, :signature => "Bob" }) }))
    }.to_not(change { User.agents.count })
  end

  it("customer may not create agent") do
    sign_in(bob)

    expect {
      post(:create, :params => ({ :user => ({ :email => "harry@getbrimir.com", :password => "testtest", :password_confirmation => "testtest", :agent => true, :signature => "Harry" }) }))
    }.to_not(change { User.agents.count })

    expect(response).to have_http_status(:unauthorized)
  end

  it("should update user") do
    sign_in(alice)

    expect {
      patch(:update, :params => ({ :id => bob.id, :user => ({ :email => "test@test.test", :label_ids => ([bug_label.id]) }) }))
    }.to(change { Labeling.count })
    
    bob.reload

    expect(bob.email).to(eq("test@test.test"))
    expect(bob.labels.count).to(eq(1))
    expect(bob.labels.first).to(eq(bug_label))
    expect(response).to redirect_to(users_path)
  end

  it("should not update user") do
    sign_in(bob)
    expect {
      patch(:update, :params => ({ :id => bob.id, :user => ({ :email => "test@test.test", :label_ids => ([bug_label.id]), :password => "testtest", :password_confirmation => "testtest" }) }))
    }.to_not(change { Labeling.count })

    bob.reload

    expect(bob.email).to_not(eq("test@test.test"))
    expect(bob.labels.count).to(eq(0))
    expect(response).to redirect_to(tickets_path)
  end

  it("should remove user") do
    sign_in(alice)

    expect {
      delete(:destroy, :params => ({ :id => bob.id }))
    }.to_not(change { User.count })

    expect(response).to have_http_status(:unauthorized)

    bob.tickets.destroy_all
    bob.replies.destroy_all

    expect {
      delete(:destroy, :params => ({ :id => bob.id }))
    }.to(change { User.count }.by(-1))

    expect(response).to redirect_to(users_path)
  end

  it("should create a schedule") do
    alice.schedule = nil
    alice.save!
    alice.reload
    
    sign_in(alice)

    expect(alice.schedule).to(be_nil)
    expect(alice.schedule_enabled).to be_falsey
    
    expect {
      patch(:update, :params => ({ :id => alice.id, :user => ({ :email => alice.email, :schedule_enabled => true, :schedule_attributes => ({ :start => "08:00", :end => "18:00" }) }) }))
    }.to(change { Schedule.count })

    expect(response).to redirect_to(users_path)
    
    alice.reload
    expect(Time.zone.parse("08:00")).to(eq(alice.schedule.start))
    expect(Time.zone.parse("18:00")).to(eq(alice.schedule.end))
  end
end
