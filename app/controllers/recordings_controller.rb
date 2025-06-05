class RecordingsController < ApplicationController
  before_action :authenticate_user!
  before_action :recording_params

  def create
    @page = Page.find(params[:page_id])
    @recording = Recording.new(recording_params)
    @recording.page = @page
    @recording.user = current_user
    if @recording.save
      render turbo_stream: turbo_stream.replace(
        "audio-#{@page.id}-#{@recording.language}",
        partial: 'pages/recording_form', locals: {
          page: @page, language: @recording.language, recording: @recording
        }
      )
    else
      render json: { error: "Failed to save recording" }, status: :unprocessable_entity
    end
  end

  private

  def recording_params
    params.require(:recording).permit(:audio, :language)
  end
end
