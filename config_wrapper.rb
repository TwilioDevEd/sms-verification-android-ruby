require 'dotenv/load'

module Config
    class << self
        attr_reader :twilio_account_sid, :twilio_auth_token,
                    :sending_phone_number, :app_hash, :client_secret
    end

    @twilio_account_sid = ENV.fetch('TWILIO_ACCOUNT_SID', "ACXXXXXXXXXX")
    @twilio_auth_token = ENV.fetch('TWILIO_AUTH_TOKEN', "fake_auth_token")

    @sending_phone_number = ENV.fetch('SENDING_PHONE_NUMBER', "+15550421337")
    @app_hash = ENV.fetch('APP_HASH', "fake")
    @client_secret = ENV.fetch('CLIENT_SECRET', "secret")
end