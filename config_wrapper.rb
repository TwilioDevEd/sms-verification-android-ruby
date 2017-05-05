require 'dotenv/load'

module Config
    class << self
        attr_reader :twilio_api_key, :twilio_api_secret, :twilio_account_sid,
                    :sending_phone_number, :app_hash, :client_secret
    end

    @twilio_api_key = ENV.fetch('TWILIO_API_CLIENT', 'SKXXXXXXXXXX')
    @twilio_api_secret = ENV.fetch('TWILIO_API_SECRET', "super_api_super_secret")
    @twilio_account_sid = ENV.fetch('TWILIO_ACCOUNT_SID', "ACXXXXXXXXXX")

    @sending_phone_number = ENV.fetch('SENDING_PHONE_NUMBER', "+15550421337")
    @app_hash = ENV.fetch('APP_HASH', "fake")
    @client_secret = ENV.fetch('CLIENT_SECRET', "secret")
end