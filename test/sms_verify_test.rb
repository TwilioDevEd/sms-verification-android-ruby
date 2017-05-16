require 'minitest/autorun'
require 'logger'
require_relative 'test_helper'
require File.join(File.dirname(__FILE__), "..", "sms_verify.rb")


describe SmsVerify do
  let(:otp) { 123456 }
  let(:sending_phone_number) { '+15550005555' }
  let(:phone_number) { '+10123456789' }
  let(:app_hash) { 'fake_hash' }
  let(:twilio_client) { Minitest::Mock.new }
  let(:twilio_client_messages) { Minitest::Mock.new }
  let(:twilio_options) { Hash }

  subject { SmsVerify.new twilio_client, sending_phone_number, app_hash }

  before do
    twilio_client_messages.expect :create, nil, [twilio_options]
    twilio_client.expect :messages, twilio_client_messages
    subject.logger = Logger.new(StringIO.new)
  end

  describe '#generate_one_time_code' do
    it 'generates a random number' do
      subject.generate_one_time_code.must_be_kind_of Integer
      subject.generate_one_time_code.to_s.size.must_equal 6
    end
  end

  describe '#request' do
    let(:twilio_options) do
      {
        to: phone_number,
        from: sending_phone_number,
        body: "[#] Use 123456 as your code for the app!\n fake_hash"
      }
    end

    it 'creates and sends a twilio message' do
      # Act
      subject.stub :generate_one_time_code, otp do
        subject.request phone_number
      end

      # Expect
      twilio_client.verify
      twilio_client_messages.verify
    end
  end

  describe '#verify_sms' do
    describe 'when code has *not* been requested' do
      it 'returns false' do
        # Act
        ret = subject.verify_sms phone_number, 'fake'

        # Expect
        ret.must_be_falsey
      end
    end

    describe 'when code was already requested' do
      before do
        subject.stub :generate_one_time_code, otp do
          subject.request phone_number
        end
      end

      describe 'when sms code matches requested code' do
        it 'returns true' do
          #Act
          ret = subject.verify_sms phone_number, "[#] Use #{otp} as your code for the app!"

          # Expect
          ret.must_be_truthy
        end
      end

      describe 'when sms code does *not* match requested code' do
        it 'returns false' do
          # Act
          ret = subject.verify_sms phone_number, "[#] Use #{otp + 1} as your code for the app!"

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
        ret = subject.reset phone_number

        # Expect
        ret.must_be_falsey
      end
    end

    describe 'when code was already requested' do
      before do
        subject.stub :generate_one_time_code, otp do
          subject.request phone_number
        end
      end

      it 'returns true' do
        # Act
        ret = subject.reset phone_number

        # Expect
        ret.must_be_truthy
      end

      describe 'if code has already been reset' do
        it 'returns false' do
          # Act
          ret_before = subject.reset phone_number
          ret_after = subject.reset phone_number

          # Expect
          ret_before.must_be_truthy
          ret_after.must_be_falsey
        end
      end
    end
  end
end
