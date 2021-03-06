class SettingsController < ApplicationController
  include PaymentCommons

  before_filter :authenticate_user!

  def show
    enqueue_mix_panel_event "Visits Settings Page"

    get_friends_purchases
    load_payments

    @card_last_4_digits = if current_user.stripe_customer_token && customer = stripe_customer
      customer.active_card.last4
    end
  end

  def update
    if current_user.update_attributes(params[:user])
      if params[:user][:password] && params[:user][:password_confirmation]
        sign_in current_user, :bypass => true
      end
      render :json => {:success => true, :description => "User Settings were updated"}
    else
      render :json => {:error => true, :description => "There was an error", :errors => current_user.errors.full_messages.to_sentence}
    end
  end

  def update_password
    if current_user.update_with_password(params[:user])
      sign_in current_user, :bypass => true
      render :json => {:success => true, :description => "User Settings were updated"}
    else
      render :json => {:error => true, :description => "There was an error", :errors => current_user.errors.full_messages.to_sentence}
    end
  end

  # DELETE /settings/credit_card
  def credit_card
    customer = stripe_customer
    current_user.stripe_customer_token = nil
    current_user.save!
    customer.delete
    render :json => {:success => true, :description => "The Credit Card was deleted"}
  end

  # DELETE /settings/facebook_connection
  def facebook_connection
    if current_user.update_attributes({:facebook_uid => nil, :facebook_secret => nil, :facebook_secret => nil, :has_facebook => false})
      render :json => {:success => true, :description => "Disconnected from facebook"}
    else
      render :json => {:error => true, :description => "There was an error", :errors => current_user.errors.full_messages.to_sentence}
    end
  end

  # DELETE /settings/twitter_connection
  def twitter_connection
    if current_user.update_attributes({:twitter_uid => nil, :twitter_secret => nil, :twitter_token => nil, :has_twitter => false})
      render :json => {:success => true, :description => "Disconnected from twitter"}
    else
      render :json => {:error => true, :description => "There was an error", :errors => current_user.errors.full_messages.to_sentence}
    end
  end

  private
  def stripe_customer
    Stripe::Customer.retrieve current_user.stripe_customer_token
  rescue Stripe::InvalidRequestError
    nil
  end
end
