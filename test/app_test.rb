require 'minitest/autorun'
require 'minitest-assert-json-equal'
require_relative 'test_helper'
require 'rack/test'
require File.join(File.dirname(__FILE__), "..", "app.rb")

describe SmsVerification::App do
  include Rack::Test::Methods

  let(:sms_verify) { Minitest::Mock.new }
  let(:app) do
    SmsVerification::App.tap { |app| app.class_variable_set('@@sms_verify', sms_verify) }
  end

  describe 'POST /api/request' do
    before do
      sms_verify.expect :request, nil, [String]
      sms_verify.expect :expiration_interval, 900
    end

    describe 'without parameters' do
      it 'responds with status code 400' do
        # Act
        post '/api/request'

        # Expect
        _(last_response.status).must_equal 400
        _(last_response.body).must_equal 'Both client_secret and phone are required.'
      end
    end

    { client_secret: 'secret', phone: '+15550421337' }.each do |key, value|
      describe 'when only #{key} is sent' do
        it 'responds with status code 400' do
          # Act
          post '/api/request', { key => value }
          # Expect
          _(last_response.status).must_equal 400
          _(last_response.body).must_equal 'Both client_secret and phone are required.'
        end
      end
    end

    describe 'with invalid secret' do
      it 'responds with status code 400' do
        # Act
        post '/api/request', client_secret: 'lol', phone: '+15550421337'

        # Expect
        _(last_response.status).must_equal 400
        _(last_response.body).must_equal 'The client_secret parameter does not match.'
      end
    end

    describe 'with correct parameters' do
      it 'responds successfully' do
        # Act
        post '/api/request', client_secret: 'secret', phone: '+15550421337'

        # Expect
        _(last_response).must_be :ok?
        _(last_response.body).must_equal_json({success: true, time: 900}.to_json)
      end
    end
  end

  describe 'POST /api/verify' do
    describe 'without parameters' do
      it 'responds with status code 400' do
        # Act
        post '/api/verify'

        # Expect
        _(last_response.status).must_equal 400
        _(last_response.body).must_equal 'The client_secret, phone, and sms_message are required.'
      end
    end

    { client_secret: 'secret', phone: '+15550421337', sms_message: 'fake sms' }.each do |key, value|
      describe 'when only #{key} is sent' do
        it 'responds with status code 400' do
          # Act
          post '/api/verify', { key => value }
          # Expect
          _(last_response.status).must_equal 400
          _(last_response.body).must_equal 'The client_secret, phone, and sms_message are required.'
        end
      end
    end

    describe 'with invalid secret' do
      it 'responds with status code 400' do
        # Act
        post '/api/verify', client_secret: 'lol', phone: '+15550421337',
          sms_message: 'fake sms'

        # Expect
        _(last_response.status).must_equal 400
        _(last_response.body).must_equal 'The client_secret parameter does not match.'
      end
    end

    describe 'with correct parameters' do
      let(:phone_number) { '+15550421337'}
      let(:sms_message) { 'fake sms'}

      before do
        sms_verify.expect :verify_sms, verify_sms_returns, [phone_number, sms_message]
      end

      describe 'when sms message was successfully verified' do
        let(:verify_sms_returns) { true }

        it 'responds successfully' do
          # Act
          post '/api/verify', client_secret: 'secret', phone: phone_number, sms_message: sms_message

          # Expect
          _(last_response).must_be :ok?
          _(last_response.body).must_equal_json({success: true, phone: '+15550421337'}.to_json)
        end
      end

      describe 'when sms message could *not* be verified' do
        let(:verify_sms_returns) { false }

        it 'responds successfully with error message' do
          # Act
          post '/api/verify', client_secret: 'secret', phone: phone_number, sms_message: sms_message

          # Expect
          _(last_response).must_be :ok?
          _(last_response.body).must_equal_json({success: false, message: 'Unable to validate code for this phone number'}.to_json)
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
        _(last_response.status).must_equal 400
        _(last_response.body).must_equal 'Both client_secret and phone are required.'
      end
    end

    { client_secret: 'secret', phone: '+15550421337' }.each do |key, value|
      describe 'when only #{key} is sent' do
        it 'responds with status code 400' do
          # Act
          post '/api/reset', { key => value }
          # Expect
          _(last_response.status).must_equal 400
          _(last_response.body).must_equal 'Both client_secret and phone are required.'
        end
      end
    end

    describe 'with invalid secret' do
      it 'responds with status code 400' do
        # Act
        post '/api/reset', client_secret: 'lol', phone: '+15550421337'

        # Expect
        _(last_response.status).must_equal 400
        _(last_response.body).must_equal 'The client_secret parameter does not match.'
      end
    end

    describe 'with correct parameters' do
      let(:phone_number) { '+15550421337'}

      before do
        sms_verify.expect :reset, reset_returns, [phone_number]
      end

      describe 'when sms message was successfully reset' do
        let(:reset_returns) { true }

        it 'responds successfully' do
          # Act
          post '/api/reset', client_secret: 'secret', phone: phone_number

          # Expect
          _(last_response).must_be :ok?
          _(last_response.body).must_equal_json({success: true, phone: phone_number}.to_json)
        end
      end

      describe 'when sms message could *not* be reset' do
        let(:reset_returns) { false }

        it 'responds successfully with error message' do
          # Act
          post '/api/reset', client_secret: 'secret', phone: phone_number

          # Expect
          _(last_response).must_be :ok?
          _(last_response.body).must_equal_json({success: false, message: 'Unable to reset code for this phone number'}.to_json)
        end
      end
    end
  end
end