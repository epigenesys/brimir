# == Schema Information
#
# Table name: labelings
#
#  id             :integer          not null, primary key
#  labelable_type :string
#  created_at     :datetime
#  updated_at     :datetime
#  label_id       :integer
#  labelable_id   :integer
#
# Indexes
#
#  index_labelings_on_label_id                         (label_id)
#  index_labelings_on_labelable_type_and_labelable_id  (labelable_type,labelable_id)
#  unique_labeling_label                               (label_id,labelable_id,labelable_type) UNIQUE
#

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
