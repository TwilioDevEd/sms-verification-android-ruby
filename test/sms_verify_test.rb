require 'minitest/autorun'
require 'logger'
require_relative 'test_helper'
require File.join(File.dirname(__FILE__), "..", "sms_verify.rb")


describe SmsVerify do
  let(:phone_number) { '1234567890' }
  let(:app_hash) { 'fake_hash' }
  let(:verification_service_sid) { 'VAXXX'}
  let(:country_code) { 'XX'}
  let(:twilio_client) { Minitest::Mock.new }
  let(:lookup_number) { Minitest::Mock.new }
  let(:twilio_client_lookup) { Minitest::Mock.new }
  let(:twilio_client_lookups) { Minitest::Mock.new }
  let(:twilio_verify) { Minitest::Mock.new}
  let(:verify_service) { Minitest::Mock.new}
  let(:verification) { Minitest::Mock.new}
  let(:twilio_client_verifications) { Minitest::Mock.new }
  let(:lookup_options) { Hash }
  let(:verify_options) { Hash }

  subject { SmsVerify.new twilio_client, verification_service_sid, country_code, app_hash }

  before do
    lookup_number.expect :phone_number, phone_number
    twilio_client_lookup.expect :fetch, lookup_number, [lookup_options]
    twilio_client_lookups.expect :phone_numbers, twilio_client_lookup, [phone_number]

    twilio_client.expect :lookups, twilio_client_lookups

    subject.logger = Logger.new(StringIO.new)
  end

  describe '#request' do
    let(:lookup_options) do
      {
        country_code: country_code
      }
    end
    let(:verify_options) do
      {
        to: phone_number,
        channel: 'sms',
        app_hash: app_hash
      }
    end
    it 'does a lookup on the phone number' do
      # Act
      subject.request phone_number
      

      # Expect
      lookup_number.verify
      twilio_client_lookup.verify
      twilio_client_lookups.verify
      twilio_client.verify
    end
  end

end
