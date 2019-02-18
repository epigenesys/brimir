require("rails_helper")
RSpec.describe(User, :type => :model) do
  let(:emile) { FactoryBot.create(:user, email: 'ender@xxxx.com', locale: :fr) }

  it("should return user locale") { expect(emile.locale).to eq :fr }

  it("should fall back to default locale") do
    user = FactoryBot.build(:user, locale: nil)
    expect(user.locale).to eq :en
  end
end
