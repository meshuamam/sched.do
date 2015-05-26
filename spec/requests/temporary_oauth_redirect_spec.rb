require 'spec_helper'

describe 'root url with auth=yammer' do
  it 'redirects to oauth callback' do
    get '/?auth=yammer&code=abc'

    expect(response).to redirect_to('/auth/google_oauth2/callback?auth=yammer&code=abc')
  end
end
