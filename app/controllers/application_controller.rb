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

class ApplicationController < ActionController::Base

  include MultiTenancy

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end
  protect_from_forgery with: :exception

  before_action :load_tenant
  before_action :authenticate_user!
  before_action :set_locale
  before_action :load_labels, if: :user_signed_in?
  before_action :show_joyride, if: :user_signed_in?, unless: :devise_controller?

  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    if Rails.env == :production
      redirect_to root_url, alert: exception.message
    else
      # for tests and development, we want unauthorized status codes
      render plain: exception, status: :unauthorized
    end
  end

  def permitted_params
    # Delete params we don't want allowed
    params.delete(:utf8)
    params.delete(:button)
    params.delete(:id)

    # Permit params (used by the 'labels' in the sidebar and the CSV export)
    params.permit(:assignee_id, :q, :status, :label_id, :order)
  end

  helper_method :permitted_params

  protected

  def show_joyride
    @show_joyride = false
    if current_user.agent? && current_user.sign_in_count == 1 && !session[:seen_joyride]
      session[:seen_joyride] = true
      @show_joyride = true
    end
  end

  def load_labels
    @labels = Label.viewable_by(current_user).ordered
  end

  def set_locale
    @time_zones = ActiveSupport::TimeZone.all.map(&:name).sort
    @locales = I18n.available_locales.map do |locale|
      [I18n.translate(:language_name, locale: locale), locale]
    end

    if user_signed_in? && !current_user.locale.blank?
      I18n.locale = current_user.locale
    else
      locale = http_accept_language.compatible_language_from(@locales)

      if Tenant.current_tenant.ignore_user_agent_locale? || locale.blank?
        I18n.locale = Tenant.current_tenant.default_locale
      else
        I18n.locale = locale
      end
    end

    @rtl = %i(ar fa).include?(I18n.locale)
  end
end
