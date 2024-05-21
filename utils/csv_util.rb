module CsvUtil
  def get_random_comments_csv(path)
    CSV.foreach(path, headers: true).to_a.sample(6)
  end

  def generate_random_date
    # Generate a random date between 2022-06-01 and Today
    start_date = Date.new(2022, 9, 1)
    end_date = Date.today
    random_date = start_date + rand(end_date - start_date)
    random_date.strftime('%Y-%m-%d')
  end
end
