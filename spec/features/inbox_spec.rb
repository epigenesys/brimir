require 'rails_helper'

feature 'Inbox' do

  context 'Given I am not logged in' do
    context 'When I try to visit the inbox' do
      scenario 'I am asked to log in' do
        visit tickets_path
        expect(page).to have_content 'You need to sign in or sign up before continuing.'
      end
    end
  end

  context 'Given I am logged in as an agent', js: true do
    before do
      login_as create(:user, :with_agent)
      ticket1 = create(:ticket, subject: 'Help Needed', priority: :low)
      ticket2 = create(:ticket, subject: 'Please assist', priority: :high)
      ticket1.update! subject: 'Help Needed!'
    end

    context 'When I visit the inbox' do
      scenario 'I can see tickets ordered by latest updated' do
        visit tickets_path
        position_of_ticket1 = page.body.index('Help Needed!')
        position_of_ticket2 = page.body.index('Please assist')
        expect(position_of_ticket1).to be < position_of_ticket2
      end

      scenario 'I can optionally order the tickets by priority' do
        visit tickets_path
        find('#select-order-dropdown').click
        click_link 'Priority order'
        position_of_ticket1 = page.body.index('Help Needed!')
        position_of_ticket2 = page.body.index('Please assist')
        expect(position_of_ticket1).to be > position_of_ticket2
      end
    end
  end

end
