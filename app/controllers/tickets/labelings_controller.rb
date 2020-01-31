class Tickets::LabelingsController < ApplicationController
  load_and_authorize_resource :labeling

  def new
    @labeling = Labeling.new(labelable: Ticket.find(params[:ticket_id]))

    @labeling.build_label if @labeling.label.nil?

    render 'labelings/new'
  end

end