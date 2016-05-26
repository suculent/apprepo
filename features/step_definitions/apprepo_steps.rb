require './lib/apprepo.rb'

Given(/^an Apprepo$/) do
  @apprepo = Apprepo.new
end

When(/^I send it the run message$/) do
  @result = @apprepo.run
end

When(/^I send it the submit message$/) do
  @result = @apprepo.submit
end

When(/^I send it the download_manifest message$/) do
  @result = @apprepo.download_manifest
end

Then(/^I should see "([^"]*)"$/) do |_arg1|
  puts @result
end
