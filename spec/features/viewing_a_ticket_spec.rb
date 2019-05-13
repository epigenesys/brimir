require 'rails_helper'

feature 'Viewing a ticket' do

  context 'Given I am logged in as an agent' do
    context 'When I open a ticket' do
      scenario 'Then I see its content and replies' do
        login_as create(:user, :with_agent)
        ticket = create(:ticket, subject: 'Help Needed', content: 'Please help me I am really stuck!')
        create(:reply, ticket: ticket)

        visit tickets_path
        click_link 'Help Needed'

        expect(current_path).to eq ticket_path(ticket)
        expect(page).to have_content 'Please help me I am really stuck!'
        expect(page).to have_content 'This is reply 1'
      end
    end
  end

end
