class HealthChecksController < ApplicationController

  skip_before_action :authenticate_user!, only: [:show]
  skip_authorization_check only: [:show]

  def show
    Rails.logger.silence do
      render plain: 'This system is up and running'
    end
  end

end
