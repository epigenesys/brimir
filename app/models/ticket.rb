# == Schema Information
#
# Table name: tickets
#
#  id                       :integer          not null, primary key
#  content                  :text
#  content_type             :string           default("html")
#  locked_at                :datetime
#  orig_cc                  :string
#  orig_to                  :string
#  priority                 :integer          default("unknown"), not null
#  raw_message_content_type :string
#  raw_message_file_name    :string
#  raw_message_file_size    :bigint(8)
#  raw_message_updated_at   :datetime
#  status                   :integer          default("open"), not null
#  subject                  :string
#  created_at               :datetime
#  updated_at               :datetime
#  assignee_id              :integer
#  locked_by_id             :integer
#  message_id               :string
#  to_email_address_id      :integer
#  user_id                  :integer
#
# Indexes
#
#  index_tickets_on_assignee_id          (assignee_id)
#  index_tickets_on_locked_by_id         (locked_by_id)
#  index_tickets_on_message_id           (message_id)
#  index_tickets_on_priority             (priority)
#  index_tickets_on_status               (status)
#  index_tickets_on_to_email_address_id  (to_email_address_id)
#  index_tickets_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignee_id => users.id)
#  fk_rails_...  (locked_by_id => users.id)
#  fk_rails_...  (to_email_address_id => email_addresses.id)
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

class Ticket < ApplicationRecord
  include CreateFromUser
  include EmailMessage
  include TicketMerge

  validates_presence_of :user_id

  belongs_to :user, optional: false
  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :to_email_address, -> { EmailAddress.verified }, class_name: 'EmailAddress', optional: true
  belongs_to :locked_by, class_name: 'User', optional: true

  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings

  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :notified_users, source: :user, through: :notifications

  has_many :status_changes, dependent: :destroy

  has_and_belongs_to_many :unread_users, class_name: 'User'

  enum status: [:open, :closed, :deleted, :waiting, :merged]
  enum priority: { idea: -1, unknown: 0, low: 1, medium: 2, high: 3, critical: 4 }

  after_update :log_status_change
  after_create :create_status_change, :create_message_id_if_blank

  def self.active_labels(status)
    label_ids = where(status: Ticket.statuses[status])
        .joins(:labelings)
        .pluck(:label_id)
        .uniq

    return Label.where(id: label_ids)
  end

  scope :by_label_id, ->(label_id) {
    if label_id.to_i > 0
      joins(:labelings).where(labelings: { label_id: label_id })
    end
  }

  scope :by_status, ->(status) {
    if status
      where(status: Ticket.statuses[status.to_sym])
    else
      all
    end
  }

  scope :filter_by_assignee_id, ->(assignee_id) {
    if !assignee_id.nil?
      if assignee_id.to_i == 0
        where(assignee_id: nil)
      else
        where(assignee_id: assignee_id)
      end
    else
      all
    end
  }

  scope :filter_by_user_id, ->(user_id) {
    if user_id
      where(user_id: user_id)
    else
      all
    end
  }

  scope :search, ->(term) {
    if !term.nil?
      term.gsub!(/[\\%_]/) { |m| "!#{m}" }
      term = "%#{term.downcase}%"
      joins(:user).
      where('LOWER(subject) LIKE :term ESCAPE :escaped_characters
          OR LOWER(content) LIKE :term ESCAPE :escaped_characters
          OR LOWER(users.email) LIKE :term ESCAPE :escaped_characters',
          term: term, escaped_characters: '!')
    end
  }

  scope :ordered, ->(order_by = nil) {
    if order_by.present?
      order(order_by, 'created_at DESC').reverse_order
    else
      order(:updated_at).reverse_order
    end
  }

  scope :viewable_by, ->(user) {
    if !user.agent? || user.labelings.count > 0
      ticket_ids = Labeling.where(label_id: user.label_ids)
          .where(labelable_type: 'Ticket')
          .pluck(:labelable_id)

      # all notified tickets
      ticket_ids += Notification.where(user: user)
          .where(notifiable_type: 'Ticket')
          .pluck(:notifiable_id)

      where('tickets.id IN (?) OR tickets.user_id = ? OR tickets.assignee_id = ?',
          ticket_ids, user.id, user.id)
    end
  }

  scope :unlocked_for, ->(user) {
    where('locked_by_id IN (?) OR locked_at < ?', [user.id, nil], Time.zone.now - 5.minutes)
  }

  def set_default_notifications!
    users = User.agents_to_notify.select do |user|
      Ability.new(user).can? :show, self
    end
    self.notified_user_ids = users.map do |user|
      user.id if user.is_working?
    end
  end

  def is_unread?(user)
    unread_users.include? user
  end

  def mark_read(user)
    unread_users.delete user
  end

  def status_times
    total = {}

    Ticket.statuses.keys.each do |key|
      total[key.to_sym] = 0
    end

    status_changes.each do |status_change|
      total[status_change.status.to_sym] += status_change.updated_at - status_change.created_at
    end

    # add the current status as well
    current = status_changes.ordered.last
    unless current.nil?
      total[current.status.to_sym] += Time.now - current.created_at
    end

    Ticket.statuses.keys.each do |key|
      total[key.to_sym] /= 1.minute
    end

    total
  end

  def reply_from_address
    if to_email_address.nil?
      EmailAddress.default_email
    else
      to_email_address.formatted
    end
  end

  def locked?(for_user)
    locked_by != for_user && locked_by != nil && locked_at > Time.zone.now - 5.minutes
  end

  def to
    to_email_address.try :email
  end

  def self.recaptcha_keys_present?
    !Recaptcha.configuration.site_key.blank? ||
      !Recaptcha.configuration.secret_key.blank?
  end

  def save_with_label(label_name)
    if label_name
      label = Label.where(name: label_name).take
      if label
        self.labels << label
        self.save
      else
        label = Label.new(name: label_name)
        Ticket.transaction do
          label.save
          self.labels << label
          self.save
        end
      end
    else
      self.save
    end
  end

  protected
    def create_status_change
      status_changes.create! status: self.status
    end

    def create_message_id_if_blank
      if self.message_id.blank?
        self.message_id = Mail::MessageIdField.new.message_id
        self.save!
      end
    end

    def log_status_change
      if saved_changes.transform_values(&:first).include? 'status'
        previous = status_changes.ordered.last

        unless previous.nil?
          previous.updated_at = Time.now
          previous.save
        end

        status_changes.create! status: self.status
      end
    end

end
