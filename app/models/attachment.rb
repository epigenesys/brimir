# == Schema Information
#
# Table name: attachments
#
#  id                :integer          not null, primary key
#  attachable_type   :string
#  file_content_type :string
#  file_file_name    :string
#  file_file_size    :bigint(8)
#  file_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  attachable_id     :integer
#  content_id        :string
#
# Indexes
#
#  index_attachments_on_attachable_id  (attachable_id)
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

class Attachment < ApplicationRecord
  # polymorphic relation with tickets & replies
  belongs_to :attachable, polymorphic: true, optional: true

  scope :inline, -> { where.not(content_id: nil) }
  scope :non_inline, -> { where(content_id: nil) }

  has_attached_file :file,
      path: Tenant.files_path,
      url: '/attachments/:id/:style',
      styles: {
          thumb: {
              geometry: '50x50#',
              format: :jpg,
              # this will convert transparent parts to white instead of black
              convert_options: '-flatten'
          }
      }
  do_not_validate_attachment_file_type :file
  before_post_process :thumbnail?

  attr_accessor :disable_thumbnail_generation

  def thumbnail?
    # There seems to be significant issues with the thumbnail generation, but Paperclip
    # will need to be replaced with a more modern solution so we'll work around it
    # in the short-term.

    return false if disable_thumbnail_generation || !AppSettings.enable_attachment_thumbnails

    unless file_content_type.nil?

      if !file_content_type.match(/^image/).nil? &&
          system('which convert', out: '/dev/null')

        return true
      end

      return false if Rails.env.test?
      if !file_content_type.match(/pdf$/).nil? &&
          system('which gs', out: '/dev/null')

        return true
      end

    end

    return false
  end
end
