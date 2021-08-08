class GithubService < ApiService
  def repos
    endpoint = 'https://api.github.com/repos/leehopper/little-esty-shop'
    get_data(endpoint)
  end

  def contributors
    endpoint = 'https://api.github.com/repos/leehopper/little-esty-shop/contributors'
    get_data(endpoint)
  end

  def merges
    endpoint = 'https://api.github.com/repos/leehopper/little-esty-shop/pulls?state=closed'
    get_data(endpoint)
  end
end
