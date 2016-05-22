require_relative '../greeter.rb'
require_relative '../lib/apprepo.rb'

describe 'Greeter' do
  it "should say 'Hello World!' when it receives the greet() message" do
    greeter = Greeter.new
    greeting = greeter.greet
    expect(greeting).to eq 'Hello World!'
    
    
    
    apprepo = Apprepo.new()
    
  end
end
