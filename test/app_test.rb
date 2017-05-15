ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest-assert-json-equal'
require 'rack/test'
require File.join(File.dirname(__FILE__), "..", "app.rb")


class SmsVerificationTest < Minitest::Test
  include Rack::Test::Methods

  def app
    app = SmsVerification::App

    sms_verify = Minitest::Mock.new
    sms_verify.expect :request, nil, [String]
    if defined? @verify_sms_returns
      sms_verify.expect :verify_sms, @verify_sms_returns, [String, String]
    end
    if defined? @reset_returns
      sms_verify.expect :reset, @reset_returns, [String]
    end
    sms_verify.expect :expiration_interval, 900
    app.class_variable_set('@@sms_verify', sms_verify)
    return app
  end

  #
  # Test Route : /api/request
  #
  def test_request_code_without_parameter
    # Act
    post '/api/request'

    # Assert
    assert_equal 400, last_response.status
    assert_equal 'Both client_secret and phone are required.', last_response.body
  end

  def test_request_code_with_missing_parameter
    # Act
    post '/api/request', client_secret: 'secret'
    # Assert
    assert_equal 400, last_response.status
    assert_equal 'Both client_secret and phone are required.', last_response.body

    # Act
    post '/api/request', phone: '+15550421337'
    # Assert
    assert_equal 400, last_response.status
    assert_equal 'Both client_secret and phone are required.', last_response.body
  end

  def test_request_code_with_invalid_secret
    # Act
    post '/api/request', client_secret: 'lol', phone: '+15550421337'

    # Assert
    assert_equal 400, last_response.status
    assert_equal 'The client_secret parameter does not match.', last_response.body
  end

  def test_request_code_with_correct_parameter
    # Act
    post '/api/request', client_secret: 'secret', phone: '+15550421337'

    # Assert
    assert last_response.ok?
    assert_json_equal last_response.body, {success: true, time: 900}.to_json
  end

  #
  # Test Route : /api/verify
  #
  def test_verify_code_without_parameter
    # Act
    post '/api/verify'

    # Assert
    assert_equal 400, last_response.status
    assert_equal 'The client_secret, phone, and sms_message are required.', last_response.body
  end

  def test_verify_code_with_missing_parameter
    # Act
    post '/api/verify', client_secret: 'secret'
    # Assert
    assert_equal 400, last_response.status
    assert_equal 'The client_secret, phone, and sms_message are required.', last_response.body

    # Act
    post '/api/verify', phone: '+15550421337'
    # Assert
    assert_equal 400, last_response.status
    assert_equal 'The client_secret, phone, and sms_message are required.', last_response.body

    # Act
    post '/api/verify', sms_message: 'fake sms'
    # Assert
    assert_equal 400, last_response.status
    assert_equal 'The client_secret, phone, and sms_message are required.', last_response.body
  end

  def test_verify_code_with_invalid_secret
    # Act
    post '/api/verify', client_secret: 'lol', phone: '+15550421337', 
      sms_message: 'fake sms'

    # Assert
    assert_equal 400, last_response.status
    assert_equal 'The client_secret parameter does not match.', last_response.body
  end

  def test_verify_code_with_correct_parameter
    # Arrange
    @verify_sms_returns = true

    # Act
    post '/api/verify', client_secret: 'secret', phone: '+15550421337', 
      sms_message: 'fake sms'

    # Assert
    assert last_response.ok?
    assert_json_equal last_response.body, {success: true, phone: '+15550421337'}.to_json
  end

  def test_verify_code_with_incorrect_parameter
    # Arrange
    @verify_sms_returns = false

    # Act
    post '/api/verify', client_secret: 'secret', phone: '+15550421337', 
      sms_message: 'fake sms'

    # Assert
    assert last_response.ok?
    assert_json_equal last_response.body, {success: false, message: 'Unable to validate code for this phone number'}.to_json
  end

  #
  # Test Route : /api/reset
  #
  def test_reset_code_without_parameter
    # Act
    post '/api/reset'

    # Assert
    assert_equal 400, last_response.status
    assert_equal 'Both client_secret and phone are required.', last_response.body
  end

  def test_reset_code_with_missing_parameter
    # Act
    post '/api/reset', client_secret: 'secret'
    # Assert
    assert_equal 400, last_response.status
    assert_equal 'Both client_secret and phone are required.', last_response.body

    # Act
    post '/api/reset', phone: '+15550421337'
    # Assert
    assert_equal 400, last_response.status
    assert_equal 'Both client_secret and phone are required.', last_response.body
  end

  def test_reset_code_with_invalid_secret
    # Act
    post '/api/reset', client_secret: 'lol', phone: '+15550421337'

    # Assert
    assert_equal 400, last_response.status
    assert_equal 'The client_secret parameter does not match.', last_response.body
  end

  def test_reset_code_with_correct_parameter
    # Arrange
    @reset_returns = true

    # Act
    post '/api/reset', client_secret: 'secret', phone: '+15550421337'

    # Assert
    assert last_response.ok?
    assert_json_equal last_response.body, {success: true, phone: '+15550421337'}.to_json
  end

  def test_reset_code_with_incorrect_parameter
    # Arrange
    @reset_returns = false

    # Act
    post '/api/reset', client_secret: 'secret', phone: '+15550421337'

    # Assert
    assert last_response.ok?
    assert_json_equal last_response.body, {success: false, message: 'Unable to reset code for this phone number'}.to_json
  end
end