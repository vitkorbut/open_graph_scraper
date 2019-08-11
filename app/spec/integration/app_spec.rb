require 'spec_helper'

describe "OG Tags Scraper" do
  xit "ADDs OR GETs CANONICAL URL ID" do
    # let() {}
    post '/stories/', url: 'some_url'

    expect(last_response).to be_ok
  end

  xit "SCRAPE URL METADATA" do
    get '/stories/some_story_id'

    expect(last_response).to be_ok
    expect(last_response.body).to match(/The Open Graph protocol/)
  end
end
