require("rails_helper")
RSpec.describe(AttachmentsController, :type => :controller) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:charlie) { FactoryBot.create(:user, :with_agent, name: 'Charlie', email: 'charlie@xxxx.com', schedule_enabled: false) }
  let!(:ticket) { FactoryBot.create(:ticket, :with_to_email_address, user: charlie, assignee: alice) }
  let!(:tenant) { FactoryBot.create(:tenant) }
  let!(:attachment) { FactoryBot.create(:attachment, attachable: ticket) }

  describe 'attaching jpegs' do
    before do
      sign_in(alice)
      Tenant.current_domain = Tenant.first.domain
      attachment.update_attributes!(:file => fixture_file_upload(Rails.root.join('spec', 'attachments', 'default-testpage.jpg'), "image/jpeg"))
    end

    it("should get new") do
      sign_out(alice)
      get(:new, :xhr => true)
      assert_response(:success)
    end

    it("should show thumb") do
      get(:show, :params => ({ :format => :thumb, :id => attachment.id }))
      assert_response(:success)
    end

    it("should download original") do
      get(:show, :params => ({ :format => :original, :id => attachment.id }))
      assert_response(:success)
    end
  end

  describe 'attaching PDFs' do
    before do
      sign_in(charlie)
      Tenant.current_domain = Tenant.first.domain
      attachment.update_attributes!(:file => fixture_file_upload(Rails.root.join('spec', 'attachments', 'default-testpage.pdf'), "application/pdf"))
    end

    it("should get new") do
      sign_out(alice)
      get(:new, :xhr => true)
      assert_response(:success)
    end

    it("should show thumb") do
      get(:show, :params => ({ :format => :thumb, :id => attachment.id }))
      assert_response(:success)
    end

    it("should download original") do
      get(:show, :params => ({ :format => :original, :id => attachment.id }))
      assert_response(:success)
    end
  end
end
