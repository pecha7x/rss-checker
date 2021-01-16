class RssCheckerMailer < ActionMailer::Base
  default from: "rss@taganteam.com"

  def rss_reader_changes email, response
    @news_feed = response
    @title = 'UPWORK NEW JOBS'
    mail(to: email, subject: 'News Feed')
  end

  def error_notification message
    @message = message
    mail(to: ENV['RSS_ERROR_NOTIFICATION'], subject: 'Error Rss Reader')
  end


end
