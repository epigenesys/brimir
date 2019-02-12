require("rails_helper")

describe(Api::V1::TicketsController) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:ticket) { FactoryBot.create(:ticket, :with_to_email_address, user: bob, assignee: alice) }

  it("should get index") do
    sign_in(bob)
    get(:index, :params => ({ :auth_token => bob.authentication_token, :format => :json }))
    expect(response).to have_http_status(:success)
    expect(ticket).to_not(be_nil)
  end
  
  it("should show ticket") do
    sign_in(bob)
    get(:show, :params => ({ :auth_token => bob.authentication_token, :id => ticket.id, :format => :json }))
    expect(response).to have_http_status(:success)
  end

  it("should show tickets as nested resource") do
    get(:index, :params => ({ :auth_token => bob.authentication_token, :user_email => Base64.urlsafe_encode64(alice.email), :format => :json }))
    expect(response).to have_http_status(:success)
  end
  
  it("should create ticket") do
    sign_in(bob)
    expect do
      post(:create, :params => ({ :auth_token => bob.authentication_token, :ticket => ({ :content => "I need help", :from => "bob@xxxx.com", :subject => "Remote from API", :priority => "low" }), :format => :json }))
    end.to(change { Ticket.count }.by(1))
    expect(response).to have_http_status(:success)
  end
end