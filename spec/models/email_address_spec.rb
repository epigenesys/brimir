# == Schema Information
#
# Table name: email_addresses
#
#  id                 :integer          not null, primary key
#  default            :boolean          default(FALSE)
#  email              :string
#  name               :string
#  verification_token :string
#  created_at         :datetime
#  updated_at         :datetime
#

require("rails_helper")

describe EmailAddress, :type => :model do
  before { Tenant.delete_all }

  let!(:tenant) { FactoryBot.create(:tenant) }
  let!(:email_address) { FactoryBot.create(:email_address, :with_default) }

  it("should use correct default address") do
    email_address.update(verification_token: nil)
    Tenant.current_domain = Tenant.first.domain
    expect(EmailAddress.default_email).to(eq(email_address.email))
    EmailAddress.destroy_all
    expect(EmailAddress.default_email).to(eq("support@test.host"))
  end
end
