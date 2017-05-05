require 'minitest/autorun'
require File.join(File.dirname(__FILE__), "..", "sms_verify.rb")


class SmsVerifyTest < Minitest::Test
  def initialize(app)
    super(app)
    @twilio_client = Minitest::Mock.new
    @twilio_client_messages = Minitest::Mock.new
    @twilio_client_messages.expect :create, nil, [Hash]
    @twilio_client.expect :messages, @twilio_client_messages
    @sending_phone_number = '+15550005555'
    @phone_number = '+10123456789'
    @otp = 123456
    @app_hash = 'fake_hash'
  end

  def setup
    if not defined? @cache
      @cache = Minitest::Mock.new
    end
    @sms_verify = SmsVerify.new @twilio_client, @sending_phone_number, @app_hash
    @sms_verify.instance_variable_set('@cache', @cache)
  end

  def test_generate_one_time_code
    assert_match /^\d{6}$/, @sms_verify.generate_one_time_code.to_s
  end

  def test_request
    # Arrange
    @cache.expect :set, nil, [String, Integer, Hash]

    # Act
    @sms_verify.request @phone_number

    # Assert
    @twilio_client.verify
    @twilio_client_messages.verify
    @cache.verify
  end

  def test_verify_phone_without_otp
    # Arrange
    @cache.expect :get, nil, [String]

    # Act
    ret = @sms_verify.verify_sms @phone_number, 'fake'

    # Assert
    refute ret
    @cache.verify
  end

  def test_verify_phone_with_otp
    # Arrange
    @cache.expect :get, @otp, [String]

    # Act
    ret = @sms_verify.verify_sms @phone_number, "[#] Use #{@otp} as your code for the app!"

    # Assert
    assert ret
    @cache.verify
  end

  def test_verify_with_phone_with_incorrect_otp
    # Arrange
    @cache.expect :get, @otp, [String]

    # Act
    ret = @sms_verify.verify_sms @phone_number, "[#] Use #{@otp+1} as your code for the app!"

    # Assert
    refute ret
    @cache.verify
  end

  def test_reset_phone_without_otp
    # Arrange
    @cache.expect :get, nil, [String]

    # Act
    ret = @sms_verify.reset @phone_number

    # Assert
    refute ret
    @cache.verify
  end

  def test_reset_phone_with_otp
    # Arrange
    @cache.expect :get, @otp, [String]
    @cache.expect :unset, nil, [String]

    # Act
    ret = @sms_verify.reset @phone_number

    # Assert
    assert ret
    @cache.verify
  end
end
