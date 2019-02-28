require("rails_helper")

describe LabelsController, type: :controller do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:change_label) { FactoryBot.create(:label, name: 'Feature request') }
  let!(:bug_label) { FactoryBot.create(:label, name: 'Bug') }
  
  before { sign_in(alice) }
  
  render_views
  #TODO make this a view test instead, to get rid of the above "render_views"
  it("should get select2 json") do
    get(:index, :format => :json)
    expect(response).to have_http_status(:success)
    result = ActiveSupport::JSON.decode(@response.body)
    expect(result.size).to(eq(2))
    expect(result[0]["id"]).to_not(be_nil)
    expect(result[0]["text"]).to_not(be_nil)
  end
end
