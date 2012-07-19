class FakeYammer < Sinatra::Base
  cattr_accessor :activity_endpoint_hits
  cattr_accessor :messages_endpoint_hits

  def self.activity_messages_sent
    activity_endpoint_hits
  end

  def self.messages_messages_sent
    messages_endpoint_hits
  end

  def self.reset
    self.activity_endpoint_hits = 0
    self.messages_endpoint_hits = 0
  end

  post '/api/v1/activity.json' do
    self.activity_endpoint_hits += 1
    202
  end

  post '/api/v1/messages.json' do
    self.messages_endpoint_hits += 1
    202
  end
end

ShamRack.mount(FakeYammer, 'www.yammer.com', 443)
