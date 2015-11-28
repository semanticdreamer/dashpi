require "rest-client"
require "cgi"
require "json"

require 'dotenv'

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
Dotenv.load

api_key = ENV['PINGDOM_API_KEY'] || ''
user = ENV['PINGDOM_USER'] || ''
password = ENV['PINGDOM_PASSWORD'] || ''

SCHEDULER.every '1m', :first_in => 0 do
  # Get checks
  url = "https://#{CGI::escape user}:#{CGI::escape password}@api.pingdom.com/api/2.0/checks"
  response = RestClient.get(url, {"App-Key" => api_key})
  response = JSON.parse(response.body, :symbolize_names => true)

  if response[:checks]
    checks = response[:checks].map { |check|
      if check[:status] == 'up'
        state = 'up'
        last_response_time = "#{check[:lastresponsetime]}ms"
      else
        state = 'down'
        last_response_time = "DOWN"
      end

      { name: check[:name], state: state, lastRepsonseTime: last_response_time }
    }
  else
    checks = [name: "pingdom", state: "down", lastRepsonseTime: "-"]
  end

  checks.sort_by { |check| check['name'] }
  send_event('pingdom', { checks: checks })
end