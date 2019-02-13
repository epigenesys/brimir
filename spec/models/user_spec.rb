require("rails_helper")
RSpec.describe(User, :type => :model) do
  it("should return user locale") { expect(:fr).to(eq(users(:emile).locale)) }
  it("should fall back to default locale") do
    user = users(:emile)
    user.locale = nil
    expect(:en).to(eq(user.locale))
  end
end
