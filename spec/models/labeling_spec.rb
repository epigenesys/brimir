require("rails_helper")

describe(Labeling, :type => :model) do
  let!(:bug_label) { FactoryBot.create(:label, name: 'Bug') }

  it("should create label for new name") do
    expect do
      labeling = Labeling.new(:label => ({ :name => "New label" }), :labelable => Ticket.first)
      expect(labeling.label).to_not(be_nil)
      expect(labeling.label.name).to(eq("New label"))
    end.to(change { Label.count })
  end
  
  it("should not create label for existing name") do
    expect do
      labeling = Labeling.new(:label => ({ :name => bug_label.name }), :labelable => Ticket.first)
      expect(labeling.label).to_not(be_nil)
      expect(labeling.label.name).to(eq(bug_label.name))
    end.to_not(change { Label.count })
  end
end
