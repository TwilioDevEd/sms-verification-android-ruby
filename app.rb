require 'bundler'
require 'sinatra'
require 'sinatra/json'
require 'twilio-ruby'
require 'rack/parser'

require_relative 'config_wrapper'
require_relative 'sms_verify'

ENV['RACK_ENV'] ||= 'development'

module SmsVerification
  class App < Sinatra::Base
    configure do
      set :port, 3000
      set :raise_errors, true
      set :dump_errors, false
      set :show_exceptions, false
      set :root, File.dirname(__FILE__)
      use Rack::Parser, parsers: { 'application/json' => -> (data) { JSON.parse data } }
    end

    # Initialize the Twilio Client
    @@twilio_client = Twilio::REST::Client.new(
      Config.twilio_account_sid,
      Config.twilio_auth_token
    )

    @@sms_verify = SmsVerify.new(
      @@twilio_client,
      Config.sending_phone_number,
      Config.app_hash
    )

    @@configured_client_secret = Config.client_secret

    # Sends a one-time code to the user's phone number for verification
    post '/api/request' do
      client_secret = params['client_secret']
      phone = params['phone']

      unless client_secret && phone
        # send an error saying that both client_secret and phone are required
        status 400
        return 'Both client_secret and phone are required.'
      end

      if @@configured_client_secret != client_secret
        status 400
        return 'The client_secret parameter does not match.'
      end

      @@sms_verify.request(phone)

      json success: true, time: @@sms_verify.expiration_interval
    end

    post '/api/verify' do
      client_secret = params['client_secret']
      phone = params['phone']
      sms_message = params['sms_message']

      unless client_secret && phone && sms_message
        # send an error saying that both client_secret and phone are required
        status 400
        return 'The client_secret, phone, and sms_message are required.'
      end

      if @@configured_client_secret != client_secret
        status 400
        return 'The client_secret parameter does not match.'
      end

      if @@sms_verify.verify_sms(phone, sms_message)
        json success: true, phone: phone
      else
        json success: false,
             message: 'Unable to validate code for this phone number'
      end
    end

    post '/api/reset' do
      client_secret = params['client_secret']
      phone = params['phone']

      unless client_secret && phone
        # send an error saying that both client_secret and phone are required
        status 400
        return 'Both client_secret and phone are required.'
      end

      if @@configured_client_secret != client_secret
        status 400
        return 'The client_secret parameter does not match.'
      end

      if @@sms_verify.reset(phone)
        json success: true, phone: phone
      else
        json success: false,
             message: 'Unable to reset code for this phone number'
      end
    end
  end
end
