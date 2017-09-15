# frozen_string_literal: true

##
# Controller used for feedback forms
class FeedbackFormsController < ApplicationController

  def new; end

  def create
    return unless request.post?
    if validate
      FeedbackMailer.submit_feedback(params, request.remote_ip).deliver_now
      flash[:success] = t('feedback_form.success')
    end
    respond_to do |format|
      format.json do
        render json: flash
      end
      format.html do
        redirect_to params[:url]
      end
    end
  end

  protected

  def url_regex
    %r{.*href=.*|.*url=.*|.*http:\/\/.*|.*https:\/\/.*}i
  end

  def validate
    errors = []
    if params[:message].nil? || params[:message] == ''
      errors << 'A message is required'
    end
    if params[:email_address] && params[:email_address] != ''
      errors << 'You have filled in a field that makes you appear as a spammer'\
        '.  Please follow the directions for the individual form fields.'
    end
    if params[:message] =~ url_regex
      errors << 'Your message appears to be spam, and has not been sent. Pleas'\
        'e try sending your message again without any links in the comments.'
    end
    if params[:user_agent] =~ url_regex || params[:viewport] =~ url_regex
      errors << 'Your message appears to be spam, and has not been sent.'
    end
    flash[:error] = errors.join('<br/>') unless errors.empty?
    flash[:error].nil?
  end
end
