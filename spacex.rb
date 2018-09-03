require 'httparty'


launches_url = "https://api.spacexdata.com/v2/launches"
launches_response = HTTParty.get(launches_url)
launches = launches_response.parsed_response

all_dates = launches.map { |x| x['launch_date_unix'] }

all_months = all_dates.map { |x| Time.at(x).month }

counted_launches_monthly = Hash.new(0)
all_months.each { |v| counted_launches_monthly.store(v, counted_launches_monthly[v]+1) }

months_numbers = (1..12).map { |k| k }
placeholders = Array.new(12, 0)
months =  Hash[months_numbers.zip(placeholders)]

counted_launches_monthly = months.merge(counted_launches_monthly)

puts counted_launches_monthly.map { |k,v| "#{k} #{v}" }


puts launches.to_s.sum { |h| h['rocket']['second_stage']['payloads'][0][:payload_mass_kg] }


all_rockets = launches.map { |x| x['rocket']['rocket_name'] }

all_years = launches.map { |x| x['launch_year'] }

counted_launched_rockets = Hash.new(0)
all_rockets.each { |v| counted_launched_rockets.store(v, counted_launched_rockets[v]+1) }

counted_launches_per_years = Hash.new(0)
all_years.each { |v| counted_launches_per_years.store(v, counted_launches_per_years[v]+1) }

falcon1_url = "https://api.spacexdata.com/v2/rockets/falcon1"
falcon1_response = HTTParty.get(falcon1_url)
falcon1 = falcon1_response.parsed_response

falcon9_url = "https://api.spacexdata.com/v2/rockets/falcon9"
falcon9_response = HTTParty.get(falcon9_url)
falcon9 = falcon9_response.parsed_response

falcon_heavy_url = "https://api.spacexdata.com/v2/rockets/falconheavy"
falcon_heavy_response = HTTParty.get(falcon_heavy_url)
falcon_heavy = falcon_heavy_response.parsed_response

rockets_cost_per_launch = Hash.new(0)
rockets_cost_per_launch = Hash["Falcon 1" => falcon1['cost_per_launch'], "Falcon 9" => falcon9['cost_per_launch'], "Falcon Heavy" => falcon_heavy['cost_per_launch']]

total_rocket_cost = counted_launched_rockets.merge!(rockets_cost_per_launch) { |k,o,n| o*n }

puts total_rocket_cost.map { |k,v| "#{k} #{v}"}


total_launches_cost_per_year = Hash[all_years.uniq.map { |x| [x, []] } ]
years_and_rockets = launches.map { |o, i| [ o['launch_year'], o.dig('rocket', 'rocket_name') ] }
years_and_rockets.each { |x| total_launches_cost_per_year[x[0]].push(x[1]) }

total_launches_cost_per_year.each_with_index do |(key, value), index|
  sum_of_rockets = value.inject(Hash.new(0)) { |a, i| a[i] += 1; a }
  cost_per_rocket = sum_of_rockets.map { |a,b| rockets_cost_per_launch[a] * b }
  total_cost = cost_per_rocket.inject(0, &:+)
  total_launches_cost_per_year[key] = total_cost
end

puts total_launches_cost_per_year.map {|k,v| "#{k} #{v}"}
