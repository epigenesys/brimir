require("rails_helper")
RSpec.describe(EmailAddressesController, :type => :controller) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:email_address) { FactoryBot.create(:email_address, email: 'outgoing@support.bla', default: true) }

  it("should get index") do
    sign_in(alice)
    get(:index)
    assert_response(:success)
  end

  it("should not get index") do
    sign_in(bob)
    get(:index)
    assert_response(:unauthorized)
  end
  
  it("should get new") do
    sign_in(alice)
    get(:new)
    assert_response(:success)
  end
  
  it("should create") do
    sign_in(alice)
    expect do
      expect do
        expect do
          post(:create, :params => ({ :email_address => ({ :email => "support@support.bla", :default => "1" }) }))
        end.to(change { EmailAddress.count })
      end.to_not(change { EmailAddress.where(:default => true).count })
    end.to(change { ActionMailer::Base.deliveries.size })
    expect(response).to redirect_to(email_addresses_path)
    expect(ActionMailer::Base.deliveries.last["X-Brimir-Verification"].to_s).to(eq(assigns(:email_address).verification_token))
  end
  
  it("should destroy") do
    sign_in(alice)
    expect { delete(:destroy, :params => ({ :id => email_address.id })) }.to(change { EmailAddress.count }.by(-1))
    expect(response).to redirect_to(email_addresses_path)
  end
end
