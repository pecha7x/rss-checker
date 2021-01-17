class RssVersion < ActiveRecord::Base

  class << self
    def update_version(date)
      rss_version = self.first_or_initialize
      rss_version.last_pub_date = date
      rss_version.save
    end

    def last_version
      self.first_or_initialize
    end
  end
end
