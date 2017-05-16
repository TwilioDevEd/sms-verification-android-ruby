require 'minitest/autorun'
require 'minitest-assert-json-equal'
require_relative 'test_helper'
require 'rack/test'
require File.join(File.dirname(__FILE__), "..", "app.rb")

describe SmsVerification::App do
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

  describe 'POST /api/request' do
    describe 'without parameters' do
      it 'responds with status code 400' do
        # Act
        post '/api/request'

        # Expect
        last_response.status.must_equal 400
        last_response.body.must_equal 'Both client_secret and phone are required.'
      end
    end

    { client_secret: 'secret', phone: '+15550421337' }.each do |key, value|
      describe 'when only #{key} is sent' do
        it 'responds with status code 400' do
          # Act
          post '/api/request', { key => value }
          # Expect
          last_response.status.must_equal 400
          last_response.body.must_equal 'Both client_secret and phone are required.'
        end
      end
    end

    describe 'with invalid secret' do
      it 'responds with status code 400' do
        # Act
        post '/api/request', client_secret: 'lol', phone: '+15550421337'

        # Expect
        last_response.status.must_equal 400
        last_response.body.must_equal 'The client_secret parameter does not match.'
      end
    end

    describe 'with correct parameters' do
      it 'responds successfully' do
        # Act
        post '/api/request', client_secret: 'secret', phone: '+15550421337'

        # Expect
        last_response.must_be :ok?
        last_response.body.must_equal_json({success: true, time: 900}.to_json)
      end
    end
  end

  describe 'POST /api/verify' do
    describe 'without parameters' do
      it 'responds with status code 400' do
        # Act
        post '/api/verify'

        # Expect
        last_response.status.must_equal 400
        last_response.body.must_equal 'The client_secret, phone, and sms_message are required.'
      end
    end

    { client_secret: 'secret', phone: '+15550421337', sms_message: 'fake sms' }.each do |key, value|
      describe 'when only #{key} is sent' do
        it 'responds with status code 400' do
          # Act
          post '/api/verify', { key => value }
          # Expect
          last_response.status.must_equal 400
          last_response.body.must_equal 'The client_secret, phone, and sms_message are required.'
        end
      end
    end

    describe 'with invalid secret' do
      it 'responds with status code 400' do
        # Act
        post '/api/verify', client_secret: 'lol', phone: '+15550421337',
          sms_message: 'fake sms'

        # Expect
        last_response.status.must_equal 400
        last_response.body.must_equal 'The client_secret parameter does not match.'
      end
    end

    describe 'with correct parameters' do
      describe 'when sms message was successfully verified' do
        it 'responds successfully' do
          # Arrange
          @verify_sms_returns = true

          # Act
          post '/api/verify', client_secret: 'secret', phone: '+15550421337',
            sms_message: 'fake sms'

          # Expect
          last_response.must_be :ok?
          last_response.body.must_equal_json({success: true, phone: '+15550421337'}.to_json)
        end
      end

      describe 'when sms message could *not* be verified' do
        it 'responds successfully with error message' do
          # Arrange
          @verify_sms_returns = false

          # Act
          post '/api/verify', client_secret: 'secret', phone: '+15550421337',
            sms_message: 'fake sms'

          # Expect
          last_response.must_be :ok?
          last_response.body.must_equal_json({success: false, message: 'Unable to validate code for this phone number'}.to_json)
        end
      end
    end
  end

  describe 'POST /api/reset' do
    describe 'without parameters' do
      it 'responds with status code 400' do
        # Act
        post '/api/reset'

        # Expect
        last_response.status.must_equal 400
        last_response.body.must_equal 'Both client_secret and phone are required.'
      end
    end

    { client_secret: 'secret', phone: '+15550421337' }.each do |key, value|
      describe 'when only #{key} is sent' do
        it 'responds with status code 400' do
          # Act
          post '/api/reset', { key => value }
          # Expect
          last_response.status.must_equal 400
          last_response.body.must_equal 'Both client_secret and phone are required.'
        end
      end
    end

    describe 'with invalid secret' do
      it 'responds with status code 400' do
        # Act
        post '/api/reset', client_secret: 'lol', phone: '+15550421337'

        # Expect
        last_response.status.must_equal 400
        last_response.body.must_equal 'The client_secret parameter does not match.'
      end
    end

    describe 'with correct parameters' do
      describe 'when sms message was successfully reset' do
        it 'responds successfully' do
          # Arrange
          @reset_returns = true

          # Act
          post '/api/reset', client_secret: 'secret', phone: '+15550421337'

          # Expect
          last_response.must_be :ok?
          last_response.body.must_equal_json({success: true, phone: '+15550421337'}.to_json)
        end
      end

      describe 'when sms message could *not* be reset' do
        it 'responds successfully with error message' do
          # Arrange
          @reset_returns = false

          # Act
          post '/api/reset', client_secret: 'secret', phone: '+15550421337'

          # Expect
          last_response.must_be :ok?
          last_response.body.must_equal_json({success: false, message: 'Unable to reset code for this phone number'}.to_json)
        end
      end
    end
  end
end