class Holiday
  def initialize(repo_data)
    @repo_data = repo_data
  end

  def names_and_dates
    @repo_data.first(3).map do |data|
      {
        name: data[:name],
        date: data[:date].to_datetime
      }
    end
  end
end
