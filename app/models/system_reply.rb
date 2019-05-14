# == Schema Information
#
# Table name: replies
#
#  id                       :integer          not null, primary key
#  content                  :text(1073741823)
#  content_type             :string           default("html")
#  draft                    :boolean          default(FALSE), not null
#  internal                 :boolean          default(FALSE), not null
#  raw_message_content_type :string
#  raw_message_file_name    :string
#  raw_message_file_size    :bigint(8)
#  raw_message_updated_at   :datetime
#  type                     :string
#  created_at               :datetime
#  updated_at               :datetime
#  message_id               :string
#  ticket_id                :integer
#  user_id                  :integer
#
# Indexes
#
#  index_replies_on_message_id  (message_id)
#  index_replies_on_ticket_id   (ticket_id)
#  index_replies_on_user_id     (user_id)
#

class SystemReply < Reply

  def self.create_from_assignment(ticket, template)
    reply = self.create content: template.message, ticket_id: ticket.id
    reply.reply_to = ticket
    reply.set_default_notifications!
    reply.notified_users = (reply.notified_users + [ticket.user] - [ticket.assignee] - [nil]).uniq
    return reply
  end

  def to_partial_path
    'replies/reply'
  end

end
