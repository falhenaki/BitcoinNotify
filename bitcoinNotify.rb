require 'net/http'
require 'json'
require 'net/smtp'


def send_email(to,opts={})
  opts[:server]      ||= 'localhost'
  opts[:from]        ||= 'kir.a@hotmail.com'
  opts[:from_alias]  ||= 'BTC PRICE CHANGE'
  opts[:subject]     ||= "BTC PRICE CHANGE"
  opts[:body]        ||= "Important stuff!"

  msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

  Net::SMTP.start(opts[:server]) do |smtp|
    smtp.send_message msg, opts[:from], to
  end
end

def lastPrice()
  uri = URI('https://blockchain.info/ticker')
  params = { :limit => 10, :page => 3 }
  uri.query = URI.encode_www_form(params)

  res = Net::HTTP.get_response(uri)
  my_hash = JSON.parse(res.body)

  return my_hash["USD"]["last"].round.to_s
end

price = lastPrice()
btcDigits = price.split('')
first = btcDigits[0]
second = btcDigits[1]
i = 0
while 1 == 1
  btcDigits = price.split('')
  # if btc price goes below 10000
  if btcDigits.length < 5
    send_email "fawaz.alhenaki@hotmail.com", :subject => "DUDE, it just went below 10k, it's now " + price + " dollars"
	#if btc price goes above 99999
  elsif btcDigits.length > 5
    send_email "fawaz.alhenaki@hotmail.com", :subject => "DUDE, it just went above 100k, it's now " + price + " dollars"
  #change in 10s of thousands
  elsif btcDigits[0] != first
    send_email "fawaz.alhenaki@hotmail.com", :subject => "huge price movement in btc it's now " + price + " dollars"
    first = btcDigits[0]
  #change in thousands
  elsif btcDigits[1] != second
    send_email "fawaz.alhenaki@hotmail.com", :subject => "min movement in btc it's now " + price + " dollars"
    second = btcDigits[1]
  end
  
  sleep(300)
  price = lastPrice()
end
