require_relative '../utils/api_util'
require_relative '../utils/csv_util'
require_relative './woocommerce/woocommerce_api'

class WordPressCommentManager
  include ApiUtil
  include CsvUtil
  attr_reader :csv_file_path

  def initialize(csv_file_path:, site_url:, consumer_key:, consumer_secret:)
    @csv_file_path = csv_file_path
    @woocommerce_api = WooCommerceAPI.new(
      site_url,
      consumer_key,
      consumer_secret,
      {
        version: 'wc/v3'
      }
    )
  end

  def execute(action, post_id: nil)
    if post_id
      send(action, post_id)
    else
      send(action)
    end
  end

  def create_all_product_comments_csv
    ids = products_without_comments_ids
    comments = get_random_comments_csv(@csv_file_path)
    ids.each do |post_id|
      batch_create_product_review(post_id, comments)
    end
  end

  def create_random_comment(post_id)
    comments = get_random_comments_csv(@csv_file_path)
      comments.each do |row|
        create_product_review(post_id, row['comment'], row['nick'])
      end
  end
end
