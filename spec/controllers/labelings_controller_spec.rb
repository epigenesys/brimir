require("rails_helper")
RSpec.describe(LabelingsController, :type => :controller) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:ticket) { FactoryBot.create(:ticket) }
  let!(:labeling) { FactoryBot.create(:labeling) }

  before do
    sign_in(alice)
  end

  it("should create labeling") do
    expect do
      post(:create, :format => :js, :params => ({ :labeling => ({ :labelable_id => ticket.id, :labelable_type => "Ticket", :label => ({ :name => "Hello" }) }) }))
      assert_response(:success)
    end.to(change { Labeling.count })
  end

  it("should remove labeling") do
    expect do
      delete(:destroy, :params => ({ :id => (labeling), :format => :js }))
      assert_response(:success)
    end.to(change { Labeling.count }.by(-1))
  end
end
