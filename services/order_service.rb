require 'net/http'
require 'uri'
require 'json'
require 'logger'
require 'dotenv'
Dotenv.load

module OrderService
  AUTH_URL = 'https://api.youcan.shop/auth/login'
  ORDERS_URL = 'https://api.youcan.shop/orders'
  EMAIL = ENV['EMAIL']
  PASSWORD = ENV['PASSWORD']
  LOGGER = Logger.new(STDOUT)

  def self.authenticate
    uri = URI(AUTH_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['Accept'] = 'application/json'
    request.set_form_data({email: EMAIL, password: PASSWORD})
    
    response = http.request(request)
    
    if response.code == '200'
      JSON.parse(response.body)['token'] # Get token directly
    else
      LOGGER.error("Authentication failed. Response: #{response.body}")
      nil
    end
    
  rescue StandardError => e
    LOGGER.error("Authentication exception: #{e.message}")
    nil
  end

  def self.fetch_orders(token)
    uri = URI(ORDERS_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{token}"
    
    response = http.request(request)
    
    case response.code.to_i
    when 200
      JSON.parse(response.body)['data']
    when 401
      LOGGER.error("Unauthorized access to fetch orders. Check API token and permissions.")
      nil
    else
      LOGGER.error("Failed to fetch orders. Response code: #{response.code}, body: #{response.body}")
      nil
    end
  rescue StandardError => e
    LOGGER.error("Exception in fetching orders: #{e.message}")
    nil
  end

end