require 'uptimerobot'
require 'dotenv'

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
Dotenv.load

apiKey = ENV['UPTIMEROBOT_APIKEY']

SCHEDULER.every '5m', :first_in => 0 do |job|
  client = UptimeRobot::Client.new(apiKey: apiKey)

  raw_monitors = client.getMonitors['monitors']['monitor']
  
  sorted_monitors = raw_monitors.sort_by { |k| k['friendlyname'] }
  
  monitors = sorted_monitors.map { |monitor| 
    { 
      friendlyname: monitor['friendlyname'], 
      url: monitor['url'],
      status: monitor['status'],
      type: monitor['type'] === '1' ? 'http' : 'kywd',
      alltimeuptimeratio: monitor['alltimeuptimeratio'] << '%'
    }
  }

  send_event('uptimerobot', { monitors: monitors } )
end