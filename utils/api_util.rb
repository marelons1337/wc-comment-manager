module ApiUtil
  def products_without_comments_ids
    begin
      products_without_comments.map { |product| product['id'] }.compact.uniq
    rescue => exception
      byebug
    end
  end

  def all_products_ids
    download_products.map { |product| product['id'] }.compact.uniq
  end

  def products_without_comments
    products = download_products
    result = []
    site_url = @woocommerce_api.instance_variable_get('@url')

    last_id = read_last_id(site_url)

    products.each do |product|
      # Skip the products that have an id less than or equal to the last processed product id
      next if product['id'] <= last_id

      result << product if reviews(product['id']).empty?
    end

    # Write the highest product id and the site URL to the file
    highest_id = result.empty? ? last_id : [result.map { |product| product['id'] }.max, last_id].max
    write_last_id(highest_id, site_url)
    result
  end

  def read_last_id(site_url)
    last_id = 0

    # Check if the file exists
    if File.exist?('last_product.txt')
      # Read the last processed product id and the site URL from the file
      File.foreach('last_product.txt') do |line|
        file_content = line.split(',')
        if file_content[1].strip == site_url
          last_id = file_content[0].to_i
          break
        end
      end
    end

    last_id
  end

  def write_last_id(highest_id, site_url)
    # Write the highest product id and the site URL to the file
    lines = File.exist?('last_product.txt') ? File.readlines('last_product.txt') : []
    lines.reject! { |line| line.split(',')[1].strip == site_url }
    lines << "#{highest_id},#{site_url}\n"
    File.write('last_product.txt', lines.join)
  end

  def reviews(product_id)
    response = @woocommerce_api.get("products/reviews?product=#{product_id}")
    puts "Failed to retrieve reviews: #{response.parsed_response['message']}" if response.code != 200
    puts "Retrieved reviews for product #{product_id}"
    response.parsed_response
  end

  def download_products
    result = []
    page = 1
    per_page = 100 # Adjust as needed
    more_pages = true

    while more_pages
      response = @woocommerce_api.get("products", params: { per_page: per_page, page: page })

      if response.code == 200
        products = response.parsed_response
        puts "Retrieved products page #{page}, count: #{products.length}"
        result << products

        more_pages = false if products.length < per_page
        page += 1
      else
        raise "Failed to retrieve products: #{response.parsed_response['message']}"
      end
    end

    result.flatten
  end

  def batch_create_product_review(post_id, comments)
    data = {create: []}
    comments.each do |comment|
      data[:create] << {
        reviewer: comment['nick'],
        review: comment['comment'],
        product_id: post_id,
        reviewer_email: 'foo@bar.com',
        rating: 5,
        verified: true,
    }
    end

    begin
      resp = @woocommerce_api.post("products/reviews/batch", data).parsed_response
      puts "Review created: #{post_id}"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
      sleep 10
      batch_create_product_review(post_id, comments)
    end
  end

  def create_product_review(post_id, content, author)
    puts "Creating review for product #{post_id}"
    # sleep 0.5
    data = {
      reviewer: author,
      review: content,
      product_id: post_id,
      reviewer_email: 'foo@bar.com',
      rating: 5,
      verified: true,
    }

    begin
      resp = @woocommerce_api.post("products/reviews", data).parsed_response
      puts "Review created: #{post_id}"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
      sleep 10
      create_product_review(post_id, content, author)
    end
  end

  def delete_all_comments
    page = 1
    loop do
      response = @woocommerce_api.get("products/reviews?per_page=100&page=#{page}")
      p response.code && break if response.code != 200 || response.parsed_response.empty?

      response.parsed_response.each do |review|
        delete_response = @woocommerce_api.delete("products/reviews/#{review['id']}?force=true")
        puts "Deleted review #{review['id']}" if delete_response.code == 200
      end
      page += 1
    end
  end
end
