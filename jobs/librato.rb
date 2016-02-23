require 'httparty'

api_endpoint = 'https://metrics-api.librato.com/v1/metrics'
api_user = 'will@procyrion.com'
api_token = '7911b86ea270a83b61851efd45688fdd0679ee983f31a82690af19159ab556ce'

auth_credentials = { :username => api_user, :password => api_token }
request_headers = { "Accept" => "application/json" }

# the interval in seconds on which you want to query the librato API
# this should match the reporting interval for the metric you wish to query
# (see: http://dev.librato.com/v1/time-intervals)
query_interval = 1

# the name of the librato metric you want to query
metric_name = 'speed'

# query url
# (see: http://dev.librato.com/v1/get/metrics/:name)
query_url = "#{api_endpoint}/#{metric_name}?count=#{query_interval}&resolution=#{query_interval}&summarize_sources=true&breakout_sources=false"

# creates the points array from the measurements in the response
def interpolate_points(measurements)
  points = []

  measurements.each_index do |i|
    point = { x: i * 60, y: measurements[i]['count'] } # use the 'count' metric
    # point = { x: i, y: measurements[i]['value'] } # use the 'value' metric
    points << point
  end  

  points
end

SCHEDULER.every "#{query_interval}s", :first_in => 0 do
  response = HTTParty.get(query_url, :headers => request_headers, :basic_auth => auth_credentials )
  response_body = JSON.parse(response.body)

  points = interpolate_points(response_body['measurements']['all'])

  send_event("librato.#{metric_name}", points: points)
end

