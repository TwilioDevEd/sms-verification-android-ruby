require 'logger'

class SmsVerify
  attr_reader :twilio_client, :verification_service_sid, :country_code, :app_hash
  attr_accessor :logger

  def initialize(twilio_client, verification_service_sid, country_code, app_hash)
    @twilio_client = twilio_client
    @verification_service_sid = verification_service_sid
    @country_code = country_code
    @app_hash = app_hash
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end


  def get_e164_number(phone)
    phone_number = @twilio_client.lookups
      .phone_numbers(phone)
      .fetch(country_code: @country_code)

    return phone_number.phone_number
  end


  def request(phone)
    logger.info "Requesting SMS to be sent to #{phone} with #{app_hash}"

    formatted_phone = get_e164_number(phone)

    begin
      verification = @twilio_client.verify
                      .services(@verification_service_sid)
                      .verifications
                      .create(to: formatted_phone, 
                        channel: 'sms',
                        app_hash: @app_hash
                      )
      logger.info "Sent verification #{verification.sid}"
    rescue => error
      logger.warn error.inspect
      return
    end
  end

  def verify_sms(phone, sms_message)
    logger.info "Verifying #{phone}: #{sms_message}"
    
    formatted_phone = get_e164_number(phone)

    # This regexp finds the numeric code in the message
    code = /(\d+{5,7})/.match(sms_message)

    unless code
      logger.warn "No code found in the sms message"
      return false
    end
    begin
      verification_check = @twilio_client.verify
                            .services(@verification_service_sid)
                            .verification_checks
                            .create(to: formatted_phone, code: code)
    rescue => error
      logger.warn error.inspect
      return false
    end

    if verification_check.status == 'approved'
      logger.info 'Verification was approved by Verify'
      return true
    else
      logger.warn 'Mismatch between sms message code and Verify code'
      return false
    end
  end

  def reset(phone)
    logger.info "Resetting code for: #{phone}"
    # This method is not necessary with Twilio Verify

    true
  end
end
