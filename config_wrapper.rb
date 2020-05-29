require 'dotenv/load'

module Config
  class << self
    attr_reader :twilio_account_sid, :twilio_api_key,
    :twilio_api_secret, :app_hash, :client_secret,
    :verification_service_sid, :country_code
  end

  @twilio_account_sid = ENV.fetch('TWILIO_ACCOUNT_SID', 'ACXXXXXXXXXX')
  @twilio_api_key = ENV.fetch('TWILIO_API_KEY', 'fake_api_key')
  @twilio_api_secret = ENV.fetch('TWILIO_API_SECRET', 'fake_api_secret')

  @app_hash = ENV.fetch('APP_HASH', 'fake')
  @client_secret = ENV.fetch('CLIENT_SECRET', 'secret')

  @verification_service_sid = ENV.fetch('VERIFICATION_SERVICE_SID', 'VAXXXXX')
  @country_code = ENV.fetch('COUNTRY_CODE', "ZZ")
end