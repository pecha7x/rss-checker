class CreateRssCheckerTable < ActiveRecord::Migration[5.1]
  def change
    create_table :rss_versions do |t|
      t.datetime :last_pub_date
    end
  end
end
