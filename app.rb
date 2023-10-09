require 'sinatra'
require_relative 'services/order_service'
require_relative 'services/sms_service'

get '/check_for_orders' do
  OrderService::LOGGER.info("Checking for orders...")

  token = OrderService.authenticate
  return "Authentication failed. Unable to fetch orders." unless token
  
  orders = OrderService.fetch_orders(token)

  if orders.nil? || orders.empty?
    OrderService::LOGGER.error("No orders fetched or an error occurred.")
    return "No orders fetched or an error occurred."
  end
  
  OrderService::LOGGER.info("#{orders.count} orders fetched.")
  
  phone_number_to_notify = ENV['PHONE_NUMBER_TO_NOTIFY'] # Ensure this is set in your .env

  orders.each do |order_data|
    # Send SMS. for now an sms will be sent evey time we refresh which is not ideal. we should apply a backgroun job/proccess to check for new orders only.
    begin
      SMSService.send_sms(phone_number_to_notify, "You have received a new order")
    rescue StandardError => e
      OrderService::LOGGER.error("Failed to send SMS: #{e.message}")
      next
    end
  end
  
  "#{orders.count} orders checked and SMS notifications sent."
end
