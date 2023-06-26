# frozen_string_literal: true

require 'open-uri'

remote_api_url = 'https://www.googleapis.com/civicinfo/v2/representatives?address=80203&levels=country&roles=legislatorUpperBody&roles=legislatorLowerBody&key=AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
remote_data = URI.open(remote_api_url).read
pp remote_data
