require 'rails_helper'

feature 'Viewing a ticket' do

  context 'Given I am logged in as an agent' do

    let!(:agent)  { create(:user, :with_agent) }
    let!(:ticket) { create(:ticket, subject: 'Help Needed', content: 'Please help me I am really stuck!') }
    before { login_as agent }

    context 'When I open a ticket' do
      scenario 'Then I see its content and replies', js: true do
        create(:reply, ticket: ticket)
        visit tickets_path
        click_link 'Help Needed'

        expect(current_path).to eq ticket_path(ticket)
        expect(page).to have_content 'Please help me I am really stuck!'
        expect(page).to have_content 'This is reply 1'
      end

      scenario 'I can assign the ticket to me', js: true do
        expect(ticket.assignee).to be_nil
        visit ticket_path(ticket)
        within(:css, '.ticket-toolbar') { click_link 'Unassigned' }
        click_button 'Assign to me'
        sleep 0.1
        expect(ticket.reload.assignee).to eq agent
      end
    end
  end

end
