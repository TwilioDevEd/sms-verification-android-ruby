require 'minitest/autorun'
require_relative 'test_helper'
require File.join(File.dirname(__FILE__), "..", "sms_verify.rb")


describe SmsVerify do
  before do
    @twilio_client = Minitest::Mock.new
    @twilio_client_messages = Minitest::Mock.new
    @twilio_client_messages.expect :create, nil, [Hash]
    @twilio_client.expect :messages, @twilio_client_messages
    @sending_phone_number = '+15550005555'
    @phone_number = '+10123456789'
    @otp = 123456
    @app_hash = 'fake_hash'

    @cache ||= Minitest::Mock.new
    @sms_verify = SmsVerify.new @twilio_client, @sending_phone_number, @app_hash
    @sms_verify.logger = Logger.new(StringIO.new)
  end

  describe '#generate_one_time_code' do
    it 'generates a random number' do
      @sms_verify.generate_one_time_code.must_be_kind_of Integer
      @sms_verify.generate_one_time_code.to_s.size.must_equal 6
    end
  end

  describe '#request' do
    it 'creates and sends a twilio message' do
      # Act
      @sms_verify.request @phone_number

      # Expect
      @twilio_client.verify
      @twilio_client_messages.verify
    end
  end

  describe '#verify_sms' do
    describe 'when code has *not* been requested' do
      it 'returns false' do
        # Act
        ret = @sms_verify.verify_sms @phone_number, 'fake'

        # Expect
        ret.must_be_falsey
      end
    end

    describe 'when code was already requested' do
      before do
        @sms_verify.stub :generate_one_time_code, @otp do
          @sms_verify.request @phone_number
        end
      end

      describe 'when sms code matches requested code' do
        it 'returns true' do
          #Act
          ret = @sms_verify.verify_sms @phone_number, "[#] Use #{@otp} as your code for the app!"

          # Expect
          ret.must_be_truthy
        end
      end

      describe 'when sms code does *not* match requested code' do
        it 'returns false' do
          # Act
          ret = @sms_verify.verify_sms @phone_number, "[#] Use #{@otp+1} as your code for the app!"

          # Expect
          ret.must_be_falsey
        end
      end
    end
  end

  describe '#reset' do
    describe 'when code has *not* been requested' do
      it 'returns false' do
        # Act
        ret = @sms_verify.reset @phone_number

        # Expect
        ret.must_be_falsey
      end
    end

    describe 'when code was already requested' do
      before do
        @sms_verify.stub :generate_one_time_code, @otp do
          @sms_verify.request @phone_number
        end
      end

      it 'returns true' do
        # Act
        ret = @sms_verify.reset @phone_number

        # Expect
        ret.must_be_truthy
      end

      describe 'if code has already been reset' do
        it 'returns false' do
          # Act
          ret_before = @sms_verify.reset @phone_number
          ret_after = @sms_verify.reset @phone_number

          # Expect
          ret_before.must_be_truthy
          ret_after.must_be_falsey
        end
      end
    end
  end
end
