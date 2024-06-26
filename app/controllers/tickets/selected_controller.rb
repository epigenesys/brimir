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

module Tickets
  # class to interact with all selected tickets (params[:id][...])
  class SelectedController < ApplicationController
    skip_load_and_authorize_resource

    def update
      @tickets = Ticket.where(id: params[:id])

      authorize! :update, Ticket # for empty params[:id]

      return perform_merge if merge?

      @tickets.each do |ticket|
        authorize! :update, ticket
        ticket.update(ticket_params)
      end

      redirect_back fallback_location: tickets_url, notice: t(:tickets_status_modified)
    end

    protected

    def ticket_params
      params.require(:ticket).permit(:status)
    end

    def merge?
      params[:merge] == 'true'
    end

    def perform_merge
      @tickets.each do |ticket|
        authorize! :update, ticket
      end

      unless @tickets.count == 0
        merged_ticket = Ticket.merge @tickets, current_user: current_user
        redirect_to merged_ticket, notice: t(:tickets_have_been_merged)
      else
        redirect_back fallback_location: tickets_url, notice: t(:tickets_status_modified)
      end
    end
  end
end
