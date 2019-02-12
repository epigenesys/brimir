require("rails_helper")

describe(Api::V1::EmailTemplatesController) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:email_template) { FactoryBot.create(:canned_reply) }

  it("should show email template") do
    sign_in(alice)
    get(:show, :params => ({ :auth_token => bob.authentication_token, :id => email_template.id, :format => :json }))
    expect(response).to have_http_status(:success)
  end
end