require 'bundler/setup'
Bundler.require(:default)
Dotenv.load

require_relative '../lib/wordpress_comment_manager'
require_relative '../utils/site_data_util'

def print_usage
  puts "Usage: run_manager.rb <action> [options]"
  puts "Valid actions: create_all_product_comments_csv, create_random_comment"
  puts "Available options: "
  puts "  --site <site_id> - specify site id"
  puts "  --post <post_id> - specify post id"
end

action = ARGV[0]
options = ARGV[1..-1] || []
options.each_with_index do |option, index|
  case option
  when '--site'
    ENV["SITE_ID"] = options[index + 1]
  when '--post'
    ENV["POST_ID"] = options[index + 1]
  end
end

puts "Action: #{action}"
puts "Site id: #{ENV["SITE_ID"]}"
puts "Post id: #{ENV["POST_ID"]}"

unless action
  print_usage
  exit
end

def sites_data
  SiteDataUtil.all_sites_data
end

sites_data.each do |site_data|
  puts "Processing site: #{site_data[:site_url]}"
  manager = WordPressCommentManager.new(**site_data)
  manager.execute(action, post_id: ENV["POST_ID"])
end