# == Schema Information
#
# Table name: tickets
#
#  id                       :integer          not null, primary key
#  content                  :text(1073741823)
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

# This represents a ticket that has just been merged from separate tickets.
#
# Merge two tickets like this:
#
#     separate_tickets = [first_ticket, second_ticket]
#     merged_ticket = MergedTicket.from separate_tickets
#
# When providing a current_user, a merge notice is created in the other tickets
# referring to the merged ticket.
#
#     merged_ticket = MergedTicket.from separate_tickets, current_user: current_user
#
class MergedTicket < Ticket

  def initialize(separate_tickets, options = {})
    @original_tickets = separate_tickets
    @current_user = options[:current_user]
    return self
  end

  def self.from(separate_tickets, options = {})
    self.new(separate_tickets, options).merge
  end

  def merge
    oldest_original_ticket.replies << copies_of_the_replies_of_the_younger_tickets
    oldest_original_ticket.replies << younger_tickets.collect { |ticket| ticket.to_reply }
    younger_tickets.each { |ticket| ticket.create_merge_notice(oldest_original_ticket, current_user) } if current_user
    younger_tickets.each { |ticket| ticket.status = :merged; ticket.save }
    return oldest_original_ticket
  end

  def current_user
    @current_user
  end

  def original_tickets
    @original_tickets || raise('not properly initialized. @original_tickets are missing.')
  end

  def oldest_original_ticket
    @oldest_original_ticket ||= original_tickets.sort_by { |ticket| ticket.created_at }.first
  end

  def younger_tickets
    original_tickets.select { |ticket| ticket.id != oldest_original_ticket.id }
  end

  def replies_of_the_younger_tickets
    younger_tickets.collect { |ticket| ticket.replies }.flatten
  end

  def copies_of_the_replies_of_the_younger_tickets
    replies_of_the_younger_tickets.collect do |reply|
      reply_copy = reply.dup
      reply_copy.created_at = reply.created_at
      reply_copy.updated_at = reply.updated_at
      reply_copy.attachments << reply.attachments.collect { |attachment| attachment.dup }
      reply
    end
  end

end

