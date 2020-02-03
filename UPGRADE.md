# Upgrade Path

## Action Mailbox
Brimir now uses Rails' [Action Mailbox](https://guides.rubyonrails.org/action_mailbox_basics.html) to receive incoming mail. If you have a previous version of Brimir running, this then means you will have to follow the upgrade path as follows:

### MTA
If you were using the previous MTA with Postfix implementation, follow these steps:

1. Add the following to the `production.rb` file:
```
config.action_mailbox.ingress = :relay
```
2. Set the `RAILS_INBOUND_EMAIL_PASSWORD` environment variable to a unique, secure password.
3. Run the following, replacing `yoururl` with the deployment URL of your application, and INGRESS_PASSWORD to the password you set in the environment variable. 
```
bin/rails action_mailbox:ingress:postfix URL=https://yoururl.com/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=...
```

### Mailgun
If you were using the previous Mailgun implementation, do the following:

1. Remove the Mailgun config in the `production.rb` file (It may look different after your configuration was entered):
```
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  port: 587,
  address: 'smtp.mailgun.org',
  user_name: 'postmaster@yoururl.com',
  password: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-xxxxxxxx-xxxxxxxx'
}
```
2. Add the following to your `production.rb` file:
```
config.action_mailbox.ingress = :mailgun
```
3. Provide your API key by setting the `MAILGUN_INGRESS_API_KEY` environment variable.
4. Configure mailgun to forward all inbound mail to `https://yoururl.com/rails/action_mailbox/mailgun/inbound_emails/mime` Replacing `yoururl` with the deployment URL of your application.