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
# Foreign Keys
#
#  fk_rails_...  (label_id => labels.id)
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

class Labeling < ApplicationRecord
  belongs_to :label
  belongs_to :labelable, polymorphic: true

  validates_uniqueness_of :label_id, scope: [:labelable_id, :labelable_type]
  validates :label_id, presence: true

  def initialize(attributes={})
    unless attributes[:label].blank? ||
        attributes[:label][:name].blank?

      label = Label.where(name: attributes[:label][:name]).first_or_create!

      attributes[:label_id] = label.id
    else
      attributes[:label_id] = nil
    end

    attributes.delete(:label)

    super(attributes)
  end
end
