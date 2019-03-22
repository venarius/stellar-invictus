class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@stellar-invictus.com'

  layout false
  layout 'mailer', except: :support_ticket

  def support_ticket
    @created_at = DateTime.now.strftime("%F %H:%M")
    @username = params[:name]
    @category = params[:category]
    @subject = params[:subject]
    @description = params[:description]
    mail(to: 'support@stellar-invictus.com', subject: "Ticket - #{@subject}")
  end
end
