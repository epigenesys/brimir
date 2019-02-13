require("rails_helper")

describe EmailAddress, :type => :model do
  let!(:tenant) { FactoryBot.create(:tenant) }
  let!(:email_address) { FactoryBot.create(:email_address, :with_default) }

  it("should use correct default address") do
    email_address.update(verification_token: nil)
    Tenant.current_domain = Tenant.first.domain
    expect(EmailAddress.default_email).to(eq("outgoing@support.bla"))
    EmailAddress.destroy_all
    expect(EmailAddress.default_email).to(eq("support@test.host"))
  end
end
