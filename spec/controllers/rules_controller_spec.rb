require("rails_helper")

describe(RulesController) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:rule) { FactoryBot.create(:rule) }

  it("should get index") do
    sign_in(alice)
    get(:index)
    assert_response(:success)
  end

  #TODO why shouldn't it. These tests could do with a proper text to describe what's going on
  it("should not get index") do
    sign_in(bob)
    get(:index)
    assert_response(:unauthorized)
  end

  it("should get edit") do
    sign_in(alice)
    get(:edit, :params => ({ :id => (rule) }))
    assert_response(:success)
  end

  it("should update") do
    sign_in(alice)
    put(:update, :params => ({ :id => (rule), :rule => ({ :filter_field => "subject" }) }))
    expect(assigns(:rule).filter_field).to(eq("subject"))
    expect(response).to redirect_to(rules_path)
  end

  it("should get new") do
    sign_in(alice)
    get(:new)
    assert_response(:success)
  end

  it("should create") do
    sign_in(alice)
    expect do
      post(:create, :params => ({ :rule => ({ :filter_field => rule.filter_field, :filter_operation => rule.filter_operation, :filter_value => rule.filter_value, :action_operation => rule.action_operation, :action_value => rule.action_value }) }))
      expect(response).to redirect_to(rules_path)
    end.to(change { Rule.count })
  end

  it("should remove rule") do
    sign_in(alice)
    expect do
      delete(:destroy, :params => ({ :id => (rule) }))
      expect(response).to redirect_to(rules_path)
    end.to(change { Rule.count }.by(-1))
  end
end
