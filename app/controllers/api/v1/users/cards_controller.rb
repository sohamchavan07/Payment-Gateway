class Api::V1::Users::CardsController < ApplicationController
  protect_from_forgery with: :null_session

  # In a real app, these would be persisted to a vault. Here we keep minimal metadata.
  def create
    user_id = params[:id]
    payload = params.permit(:token, :brand, :last4, :exp_month, :exp_year)

    unless payload[:token].present?
      render json: { error: "token is required" }, status: :unprocessable_entity
      return
    end

    card = {
      id: SecureRandom.uuid,
      user_id: user_id,
      gateway_token: payload[:token],
      brand: payload[:brand],
      last4: payload[:last4],
      exp_month: payload[:exp_month],
      exp_year: payload[:exp_year]
    }

    # Store in session for demo; replace with DB model in production
    session[:saved_cards] ||= {}
    session[:saved_cards][user_id] ||= []
    session[:saved_cards][user_id] << card

    render json: {
      savedCardId: card[:id],
      last4: card[:last4],
      exp_month: card[:exp_month],
      exp_year: card[:exp_year]
    }
  end

  def index
    user_id = params[:id]
    cards = (session[:saved_cards] || {}).fetch(user_id, [])
    render json: cards.map { |c|
      {
        id: c[:id],
        last4: c[:last4],
        brand: c[:brand],
        exp_month: c[:exp_month],
        exp_year: c[:exp_year]
      }
    }
  end
end
