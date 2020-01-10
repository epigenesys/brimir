class MigrateReplyContentToActionText < ActiveRecord::Migration[6.0]
  include ActionView::Helpers::TextHelper

  def change
    # Solution from https://github.com/rails/rails/issues/35002#issuecomment-562311492, thanks felici
    rename_column :replies, :content, :content_old
    Reply.all.each do |reply|
      reply.update_attribute(:content, simple_format(reply.content_old))
    end
    remove_column :replies, :content_old
  end
end
