if Rails.env.production? || Rails.env.staging?
  Rails.application.config.middleware
    .use ExceptionNotification::Rack,
         email: {
           email_prefix: "[#{Rails.application.class.parent_name} Error (#{Rails.env})] ",
           sender_address: [ENV['APPLICATION_ERROR_FROM_EMAIL']],
           exception_recipients: [ENV['APPLICATION_FEEDBACK_TO_EMAIL']]
         }
end
