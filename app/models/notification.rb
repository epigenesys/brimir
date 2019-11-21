# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  notifiable_type :string
#  created_at      :datetime
#  updated_at      :datetime
#  notifiable_id   :integer
#  user_id         :integer
#
# Indexes
#
#  index_notifications_on_notifiable_type_and_notifiable_id  (notifiable_type,notifiable_id)
#  index_notifications_on_user_id                            (user_id)
#  unique_notification                                       (notifiable_id,notifiable_type,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2016 Ivaldi https://ivaldi.nl/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# tracks which user was notified for a notifiable object
class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true, optional: true
  belongs_to :user, optional: true
end
