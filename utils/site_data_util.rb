module SiteDataUtil
  class << self
    def all_sites_data
      # jesli mamy podane site_id to zwracamy tylko dane dla tego jednego sajtu
      return [get_site_data(ENV["SITE_ID"])].compact if ENV["SITE_ID"].to_i > 0

      sites_count = ENV["SITES_COUNT"].to_i
      sites_data = []
      sites_count.times do |site|
        id = site + 1
        sites_data << get_site_data(id)
      end
      sites_data
    end

    def get_site_data(id)
      id = id.to_i
      return unless ENV["SITE_#{id}_URL"]

      site_url = ENV["SITE_#{id}_URL"]
      consumer_key = ENV["SITE_#{id}_KEY"]
      consumer_secret = ENV["SITE_#{id}_SECRET"]
      csv_language = site_url.split('.').last.split('/').first
      csv_file_path = "files/comments_#{csv_language}.csv"

      { site_url: site_url, consumer_key: consumer_key, consumer_secret: consumer_secret, csv_file_path: csv_file_path }
    end
  end
end