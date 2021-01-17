class RssCheckerJob < ApplicationJob
  require 'rss'
  require 'open-uri'

  def max_attempts
    1
  end

  def before(job)
    @current_job_id = job.id
  end

  def perform(attempt = 1)
    begin
      results = {}
      results[:response] = []
      last_published_date = File.read('last_pubDate')&.to_time
      last_rss_published_date = nil
      open(ENV['RSS_LINK']) do |rss|
        feed = RSS::Parser.parse(rss)
        feed.items.each do |item|
          next if !last_published_date.nil? && item.pubDate <= last_published_date
          results[:response] << {
              description: item.description,
              title: item.title,
              url:   item.link
          }
          last_rss_published_date = item.pubDate if last_rss_published_date.nil? || last_rss_published_date <= item.pubDate
        end
      end
      File.open('last_pubDate', 'w') {|f| f.write(last_rss_published_date)} unless last_rss_published_date.nil?
      send_email_notification(ENV['EMAIL_TO_NOTIFY'], results) unless results[:response].empty?
      restart_job
    rescue => e
      if attempt > 100
        RssCheckerMailer.error_notification(e).deliver_now
      else
        attempt += 1
        RssCheckerJob.set(wait_until: 5.minutes.from_now).perform_later(attempt)
      end
    end
  end

  private

  def send_email_notification(email, data)
    RssCheckerMailer.rss_reader_changes(email, data).deliver_now
  end

  def restart_job
    RssCheckerJob.set(wait_until: 5.minutes.from_now).perform_later
  end
end
