# frozen_string_literal: true

require 'erb'
require 'csv'
require 'google/apis/civicinfo_v2'
require 'date'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/\D/, '')
  if phone_number.length === 11 && phone_number.split('')[1]
    phone_number[1..10]
  elsif phone_number.length === 10
    phone_number
  end
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue StandardError
    'You can find your local legislator by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

day = []
hour = []

def split_regestration_date(regdate)
  split_reg_date = regdate.split(" ")
  date = Time.strptime(split_reg_date[0], "%m/%d/%y")
  # Just figured out that Time class can be used with strptime and now want to "format" the Time object to output the day of the week.
  day << date.strftime("%a")
  hour << Time.parse(split_reg_date[1]).hour
end

puts 'Event Manager Initialized!'

puts "Confirm file existence: #{File.exist?('event_attendees.csv')}"

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = clean_phone_number(row[:homephone])
  puts zipcode = clean_zipcode(row[:zipcode])
  reg_date = split_regestration_date(row[:regdate])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)
  #save_thank_you_letter(id, form_letter)
end

p day
p hour
