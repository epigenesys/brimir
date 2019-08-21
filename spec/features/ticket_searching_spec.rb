require 'rails_helper'

feature 'Ticket searching' do
  before { login_as create(:user, :with_agent)  }

  let!(:inbox_ticket_1) { create(:ticket, status: :open, subject: 'Help Needed', priority: :low) }
  let!(:inbox_ticket_2) { create(:ticket, status: :open, content: 'It is broken', priority: :low) }
  let!(:inbox_ticket_3) { create(:ticket, status: :open, priority: :low, user: create(:user, email: 'test1@epigenesys.org.uk')) }

  let!(:closed_ticket_1) { create(:ticket, status: :closed, subject: 'Help Needed', priority: :low) }
  let!(:closed_ticket_2) { create(:ticket, status: :closed, content: 'It is broken', priority: :low) }
  let!(:closed_ticket_3) { create(:ticket, status: :closed, priority: :low, user: create(:user, email: 'test2@epigenesys.org.uk')) }

  let!(:deleted_ticket_1) { create(:ticket, status: :deleted, subject: 'Help Needed', priority: :low) }
  let!(:deleted_ticket_2) { create(:ticket, status: :deleted, content: 'It is broken', priority: :low) }
  let!(:deleted_ticket_3) { create(:ticket, status: :deleted, priority: :low, user: create(:user, email: 'test3@epigenesys.org.uk')) }

  let!(:waiting_ticket_1) { create(:ticket, status: :waiting, subject: 'Help Needed', priority: :low) }
  let!(:waiting_ticket_2) { create(:ticket, status: :waiting, content: 'It is broken', priority: :low) }
  let!(:waiting_ticket_3) { create(:ticket, status: :waiting, priority: :low, user: create(:user, email: 'test4@epigenesys.org.uk')) }

  context 'In the inbox' do
    before { visit tickets_path }

    specify 'I can search by subject' do
      fill_in 'q', with: 'Help Needed'
      click_button 'button'

      expect(page).to have_content "1 open ticket containing 'Help Needed'"
      expect(page).to have_css "#ticket_#{inbox_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_3.id}"
    end

    specify 'I can search by content' do
      fill_in 'q', with: 'It is broken'
      click_button 'button'

      expect(page).to have_content "1 open ticket containing 'It is broken'"
      expect(page).to have_css "#ticket_#{inbox_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_3.id}"
    end

    specify 'I can search by user email' do
      fill_in 'q', with: 'test1@epigenesys.org.uk'
      click_button 'button'

      expect(page).to have_content "1 open ticket containing 'test1@epigenesys.org.uk'"
      expect(page).to have_css "#ticket_#{inbox_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_3.id}"
    end

    context 'When no results match my search' do
      specify 'I can see a message saying no tickets were found' do
        fill_in 'q', with: 'blaaa@epigenesys.org.uk'
        click_button 'button'

        expect(page).to have_content 'No tickets found.'
      end
    end
  end

  context 'In closed tickets' do
    before do
      visit tickets_path
      click_link 'Closed'
    end

    specify 'I can search by subject' do
      fill_in 'q', with: 'Help Needed'
      click_button 'button'

      expect(page).to have_content "1 closed ticket containing 'Help Needed'"
      expect(page).to have_css "#ticket_#{closed_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_3.id}"
    end

    specify 'I can search by content' do
      fill_in 'q', with: 'It is broken'
      click_button 'button'

      expect(page).to have_content "1 closed ticket containing 'It is broken'"
      expect(page).to have_css "#ticket_#{closed_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_3.id}"
    end

    specify 'I can search by user email' do
      fill_in 'q', with: 'test2@epigenesys.org.uk'
      click_button 'button'

      expect(page).to have_content "1 closed ticket containing 'test2@epigenesys.org.uk'"
      expect(page).to have_css "#ticket_#{closed_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{inbox_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{closed_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{deleted_ticket_3.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_1.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_2.id}"
      expect(page).not_to have_css "#ticket_#{waiting_ticket_3.id}"
    end

    context 'When no results match my search' do
      specify 'I can see a message saying no tickets were found' do
        fill_in 'q', with: 'blaaa@epigenesys.org.uk'
        click_button 'button'

        expect(page).to have_content 'No tickets found.'
      end
    end
  end

end
