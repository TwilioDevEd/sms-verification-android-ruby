require 'mini_cache'

class SmsVerify
  attr_reader :cache, :twilio_client, :sender_phone_number, :app_hash, :expiration_interval

  def initialize(twilio_client, sender_phone_number, app_hash, expiration_interval=900)
    @cache = MiniCache::Store.new
    @twilio_client = twilio_client
    @sender_phone_number = sender_phone_number
    @app_hash = app_hash
    @expiration_interval = expiration_interval
  end

  def generate_one_time_code
    code_length = 6
    pow = 10 ** (code_length - 1)
    (Random.rand() * pow).ceil + pow
  end

  def request(phone)
    puts "Requesting SMS to be sent to #{phone}"

    otp = generate_one_time_code()

    @cache.set(phone, otp, expires_in: @expiration_interval)

    sms_message = "[#] Use #{otp} as your code for the app!\n #{app_hash}"
    puts sms_message

    twilio_client.messages.create(
      to: phone,
      from: sender_phone_number,
      body: sms_message
    )
  end

  def verify_sms(phone, sms_message)
    puts "Verifying #{phone}: #{sms_message}"
    otp = @cache.get(phone)

    if (otp == nil)
      puts "No cached otp value found for phone: #{phone}"
      return false
    end

    if (sms_message.index otp.to_s)
      puts 'Found otp value in cache'
      return true
    end

    puts 'Mismatch between otp value found and otp value expected'
    false
  end

  def reset(phone)
    puts "Resetting code for: #{phone}"
    otp = @cache.get(phone)

    if (otp == nil)
      puts "No cached otp value found for phone: #{phone}"
      return false
    end

    @cache.unset(phone)
    true
  end
end
