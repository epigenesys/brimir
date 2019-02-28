require("rails_helper")

describe(Api::V1::UsersController) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:charlie) { FactoryBot.create(:user, :with_agent, name: 'Charlie', email: 'charlie@xxxx.com', schedule_enabled: false) }
  let!(:ticket) { FactoryBot.create(:ticket, :with_to_email_address, assignee: alice) }
  
  it("should find a user") do
    get(:show, :params => ({ :auth_token => alice.authentication_token, :email => Base64.urlsafe_encode64(alice.email), :format => :json }))
    expect(response).to have_http_status(:success)
  end

  it("should create a user ") do
    sign_in(alice)
    expect do
      post(:create, :params => ({ :auth_token => alice.authentication_token, :user => ({ :email => "newuser@new.com" }), :format => :json }))
    end.to(change { User.count }.by(1))
    expect(response).to have_http_status(:success)
  end
end