# == Schema Information
#
# Table name: tenants
#
#  id                                              :integer          not null, primary key
#  ask_for_name                                    :boolean          default(FALSE)
#  default_locale                                  :string           default("en")
#  default_time_zone                               :string           default("Amsterdam")
#  domain                                          :string
#  first_reply_ignores_notified_agents             :boolean          default(FALSE), not null
#  from                                            :string
#  ignore_user_agent_locale                        :boolean          default(FALSE), not null
#  javascript_url                                  :string
#  notify_client_when_ticket_is_assigned_or_closed :boolean          default(FALSE), not null
#  notify_client_when_ticket_is_created            :boolean          default(FALSE)
#  notify_user_when_account_is_created             :boolean          default(FALSE)
#  share_drafts                                    :boolean          default(FALSE)
#  stylesheet_url                                  :string
#  ticket_creation_is_open_to_the_world            :boolean          default(TRUE)
#  created_at                                      :datetime         not null
#  updated_at                                      :datetime         not null
#  email_template_id                               :integer
#
# Indexes
#
#  index_tenants_on_domain             (domain) UNIQUE
#  index_tenants_on_email_template_id  (email_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_template_id => email_templates.id)
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

class Tenant < ApplicationRecord

  after_update :check_for_or_create_default_templates_for_selected_options

  has_many :email_templates

  def self.postgresql?
    connection.adapter_name == 'PostgreSQL'
  end

  # force tenants table from postgresql public schema
  # self.table_name = 'public.tenants' if postgresql?

  def self.current_domain=(domain)
    # new tenant?
    if Tenant.count == 0

      # derive a mail from address
      if ActionMailer::Base.default[:from].present?
        email = ActionMailer::Base.default[:from]
      elsif Rails.configuration.action_mailer.default_options.present?
        email = Rails.configuration.action_mailer.default_options[:from]
      else
        email = "support@#{domain}"
      end

      @@current = Tenant.create! domain: domain, from: email
    else
      @@current = Tenant.find_by!(domain: domain)
    end
    #
    # if postgresql? && available_schemas.include?(domain)
    #   ActiveRecord::Base.connection.schema_search_path = "\"#{domain}\",public"
    # end

    ActionMailer::Base.default_url_options = { host: "#{domain}" }
    Rails.configuration.devise.mailer_sender = EmailAddress.default_email

    Paperclip.interpolates :domain do |attachment, style|
      # no schema based tenants, so no subdir
      if Tenant.available_schemas.count == 0
        ''
      else
        "#{Tenant.current_tenant.domain}/"
      end
    end
  end

  def self.current_tenant
    if defined? @@current
      @@current
    else
      Tenant.new # defaults for settings
    end
  end

  def check_for_or_create_default_templates_for_selected_options
    kinds = []
    if notify_user_when_account_is_created
      kinds << :user_welcome unless EmailTemplate
          .exists?(kind: EmailTemplate.kinds[:user_welcome])
    end
    if notify_client_when_ticket_is_created
      kinds << :ticket_received unless EmailTemplate
          .exists?(kind: EmailTemplate.kinds[:ticket_received])
    end

    EmailTemplate.create_default_templates(kinds) unless kinds.empty?
  end


  def self.files_path
    ':rails_root/data/:domain:class/:attachment/:id_partition/:style.:extension'
  end

  protected
  def self.available_schemas
    []
    # if postgresql?
    #   sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*' AND
    #       nspname != 'public' AND nspname != 'information_schema'"
    #   ActiveRecord::Base.connection.query(sql).flatten
    # else
    #   []
    # end
  end
end
