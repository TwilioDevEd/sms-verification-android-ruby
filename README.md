<a href="https://www.twilio.com">
  <img src="https://static0.twilio.com/marketing/bundles/marketing/img/logos/wordmark-red.svg" alt="Twilio" width="250" />
</a>

# SMS Verification for Android - Server for Ruby and Sinatra

This sample project demonstrates how to use Twilio's SMS Messaging APIs to
verify Android application user's phone numbers. This application supports the
[SMS Retriever API](https://developers.google.com/identity/sms-retriever/overview) from Google Play Services.

You'll also need to have a sample Android application that you configure to use
these URLs to verify phone numbers. You can download that application from
its [Google Samples GitHub Repo](https://github.com/googlesamples/android-credentials/tree/master/sms-verification/android).

## Configure the sample application

To run the application, you'll need to gather your Twilio account credentials
and configure them in a file named `.env`. To create this file from an example
template, do the following in your Terminal.

```bash
cp .env.example .env
```

Open `.env` in your favorite text editor and configure the following values.
You will need all of these values before you continue.

| Config Value  | Description |
| :-------------  |:------------- |
`TWILIO_ACCOUNT_SID` | Your primary Twilio account identifier - find this [in the console here](https://www.twilio.com/console).
`TWILIO_API_KEY` | Used to authenticate - [generate one here](https://www.twilio.com/console/dev-tools/api-keys).
`TWILIO_API_SECRET` | Used to authenticate - [just like the above, you'll get one here](https://www.twilio.com/console/dev-tools/api-keys).
`APP_HASH` | Matches the Android application to the SMS message - See Google's documentation on how to [Compute your app's hash string](https://developers.google.com/identity/sms-retriever/verify#computing_your_apps_hash_string).
`CLIENT_SECRET` | Matches the Android application to the server - you can set this in the `strings.xml` file in your Android application. It must match the server's config value. You can also override it in the Settings menu of the app.
`VERIFICATION_SERVICE_SID` | This project uses Twilio Verify to send verification codes and to check their status - [create a service here](https://www.twilio.com/console/verify/services).
`COUNTRY_CODE` | Twilio Verify requires E.164 formatted phone numbers. This project uses Twilio Lookup to convert phone numbers into the expected format, based on the country for the phone number (Example: US). Find your [ISO country codes here](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements)

## Run the sample application

Now that the application is configured, we need to install our dependencies
from bundle.

```bash
bundle install
```

Now we should be all set! Run the application using the `rackup` command.

```bash
bundle exec rackup
```

Your application should now be running at [http://localhost:3000/](http://localhost:3000/).

Check your config values, and then make sure everything looks good.

## Running the server with ngrok

Your phone won't be able to access localhost directly. You'll need to create a
publicly accessible URL using a tool like [ngrok](https://ngrok.com/) to send
HTTP/HTTPS traffic to a server running on your localhost.

You can also deploy this application to a server, or to a cloud provider such
as Google App Engine.

```bash
ngrok http 3000
```

## Setting the server for the Android application

You'll need to update the Android application with the URLs from ngrok. Open up
the `strings.xml` file and add these lines:

``` xml
<string name="url_request">https://YOUR_SERVER_HERE/api/request</string>
<string name="url_verify">https://YOUR_SERVER_HERE/api/verify</string>
<string name="url_reset">https://YOUR_SERVER_HERE/api/reset</string>
```

Replace YOUR_SERVER_HERE with your server's host name or IP address.

## Running the tests

```bash
rake test
```

## License
MIT
