require 'rails_helper'

feature 'Viewing the list of unassigned tickets' do

  context 'Given I am logged in as an agent' do

    let!(:agent)  { create(:user, :with_agent) }
    let!(:ticket) { create(:ticket, subject: 'Help Needed', content: 'Please help me I am really stuck!') }
    let!(:ticket_assigned) { create(:ticket, subject: 'More Help Needed', content: 'Please help me I am really stuck!', assignee: agent) }

    scenario 'I can see only unassigned tickets', js: true do
      login_as agent

      visit '/'
      within(:css,'.unassigned-tickets-item') { click_link 'Unassigned' }
      expect(page).to have_content 'Help Needed'
      expect(page).not_to have_content 'More Help Needed'
    end

  end

end
