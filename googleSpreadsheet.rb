require 'bundler'
Bundler.require

#command run pour le terminal = bundle exec ruby spreadsheet.rb
 
# Authenticate a session with your Service Account
session = GoogleDrive::Session.from_service_account_key("client_secret.json")
 
# Get the spreadsheet by its title
spreadsheet = session.spreadsheet_by_title("googleSpreadsheet")
# Get the first worksheet
worksheet = spreadsheet.worksheets.first

require "open-uri"
require "nokogiri"
require "json"

BASE_URL = "http://annuaire-des-mairies.com/"

def email_of_a_townhall(path)
  html_content = open("#{BASE_URL}#{path}")
  document = Nokogiri::HTML(html_content)
  email = document.css("body > table > tr:nth-child(3) > td > " +
                       "table > tr:first-child > td > " +
                       "table:nth-child(8) > tr:nth-child(2) > td > " +
                       "table > tr:nth-child(4) > td:nth-child(2)").text
  email.strip.gsub(" ", "")
end

# Check that first function behave as expected
# puts "- email_of_a_townhall"
# puts email_of_a_townhall("./95/vaureal.html")

def department_townhall_urls(path)
  html_content = open("#{BASE_URL}#{path}")
  document = Nokogiri::HTML(html_content)
  links = document.css("table.Style20 a.lientxt")
  links.each_with_object({}) do |node, result|
    city = node.text
    path = node["href"]
    result[city] = path
  end
end

# Putting pieces together
result = {}
department_townhall_urls("./val-d-oise.html").each do |city, path|
  result[city] = email_of_a_townhall(path)
  break if result.size >= 10
end
puts JSON.pretty_generate(result)

worksheet.insert_rows(1, [["City", "Email_of_a_townhall"]])
worksheet.save

i = 2
result.each do |city, path|
		worksheet.insert_rows(i, [[city, path]])
		worksheet.save
		i+=1
end





