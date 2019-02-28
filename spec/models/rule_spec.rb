# == Schema Information
#
# Table name: rules
#
#  id               :integer          not null, primary key
#  action_operation :integer          default("assign_label"), not null
#  action_value     :string
#  filter_field     :string
#  filter_operation :integer          default("contains"), not null
#  filter_value     :string
#  created_at       :datetime
#  updated_at       :datetime
#

require("rails_helper")
RSpec.describe(Rule, :type => :model) do
  before do
    @filters = [:from, :subject, :content, :orig_to, :orig_cc]
    @rule = Rule.create(:filter_field => "from", :filter_value => "@", :filter_operation => "contains", :action_operation => "change_priority", :action_value => "unknown")
    @ticket = Ticket.create(:from => "test@test.nl", :orig_cc => "dummy2@example.com, dummy3@example.com", :orig_to => "support@ivaldi.nl", :content => "problem")
  end
  it("should set priority correctly") do
    priorities = Ticket.priorities.keys
    @rule.update_attribute(:action_operation, "change_priority")
    priorities.each do |priority|
      @ticket.update_attribute(:priority, "unknown")
      @rule.update_attribute(:action_value, priority)
      expect(@ticket.priority).to(eq("unknown"))
      @filters.each do |filter|
        @rule.update_attribute(:filter_field, filter)
        Rule.apply_all(@ticket)
      end
      expect(@ticket.priority).to(eq(priority))
    end
  end
  it("should set labels") do
    labels = ["bug", "change-request", "feature-request", "feedback"]
    @rule.update_attribute(:action_operation, "assign_label")
    labels.each do |label|
      @ticket.update_attribute(:labels, [])
      @rule.update_attribute(:action_value, label)
      expect(@ticket.labels.empty?).to(eq(true))
      @filters.each do |filter|
        @rule.update_attribute(:filter_field, filter)
        Rule.apply_all(@ticket)
        assert_includes(@ticket.labels.collect { |l| l.name.downcase }, label)
      end
    end
  end
  it("should assign user") do
    dummy = User.create(:email => "dummy@example.com", :agent => true, :name => "dummy", :signature => "Greets, Dummy", :authentication_token => "blabla", :notify => true)
    @rule.update_attribute(:action_operation, "assign_user")
    @rule.update_attribute(:action_value, dummy.email)
    expect(@ticket.assignee).to(be_nil)
    @filters.each do |filter|
      @rule.update_attribute(:filter_field, filter)
      Rule.apply_all(@ticket)
      expect(dummy).to(eq(@ticket.assignee))
    end
  end
  it("should add statuses") do
    statuses = Ticket.statuses.keys
    @rule.update_attribute(:action_operation, "change_status")
    statuses.each do |status|
      @ticket.update_attribute(:status, statuses[0])
      @rule.update_attribute(:action_value, status)
      expect(@ticket.status).to(eq(statuses[0]))
      @filters.each do |filter|
        @rule.update_attribute(:filter_field, filter)
        Rule.apply_all(@ticket)
        expect(@ticket.status).to(eq(status))
      end
    end
  end
  it("should set notify user") do
    dummy = User.create(:email => "dummy@example.com", :agent => true, :name => "dummy", :signature => "Greets, Dummy", :authentication_token => "blabla", :notify => true)
    @rule.update_attribute(:action_operation, "notify_user")
    @rule.update_attribute(:action_value, dummy.email)
    expect(@ticket.notified_users.empty?).to(eq(true))
    @filters.each do |filter|
      @rule.update_attribute(:filter_field, filter)
      Rule.apply_all(@ticket)
      assert_includes(@ticket.notified_users, dummy)
    end
  end
end
