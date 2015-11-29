require 'json'
require 'net/http'
require 'xmlsimple'

speedtest_cli = File.dirname(__FILE__) + '/../lib/speedtest-cli --simple --secure'
speedtest_config_url = 'https://www.speedtest.net/speedtest-config.php'

last_speedtest_ping = 0

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '3m', :first_in => 0 do |job|
  # speedtest-cli (https://github.com/sivel/speedtest-cli), a Python 
  # command line interface for testing internet bandwidth using speedtest.net
  speedtest_result = `#{speedtest_cli}`
  updown = speedtest_result.split("\n")
  
  speedtest_config_xml = Net::HTTP.get_response(URI.parse(speedtest_config_url)).body
  speedtest_config = XmlSimple.xml_in(speedtest_config_xml)

  send_event('speedtest-ping', { current: updown[0].split(' ')[1].to_f.round, last: last_speedtest_ping })
  send_event('speedtest-download', { value: updown[1].split(' ')[1].to_f.round })
  send_event('speedtest-upload', { value: updown[2].split(' ')[1].to_f.round })
  send_event('speedtest-ip', { text: speedtest_config['client'][0]['ip'] })
  
  last_speedtest_ping = updown[0].split(' ')[1].to_f.round
end