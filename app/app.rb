require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'open-uri'
require 'nokogiri'

require_relative './models/canonical_url'
require_relative './services/opengraph_service'

set :database_file, 'config/database.yml'


# POST vitaliy_korbut.hiring.keywee.io/stories?url={some_url} *** ADD OR GET CANONICAL URL ID ***
post '/stories' do
  given_url = params['url']
  canonical_url = determine_canonical_url(given_url).to_s

  return halt 500, json({'Error': 'Unexpected error happened.'}) unless canonical_url.present?
  record = CanonicalUrl.find_or_create_by(canonical_url: canonical_url)
  json(record.id)
end


# GET vitaliy_korbut.hiring.keywee.io/stories/{url-unique-id} *** SCRAPE URL METADATA ***
get '/stories/:id' do
  record = CanonicalUrl.find_by(id: params[:id])
  halt 404, json({'Error': 'Record not present, create it first.'}) unless record
  scrape(record) if record.scrape_status == 'not_scraped'
  json(prepare_metadata(record))
end


private

def scrape(record)
  record.update(scrape_status: 'pending')
  page = fetch_page(record.canonical_url)
  record.update(scrape_status: 'error') unless page

  og = OpenGraphService.new(page)
  og ? record.update(metadata: og.metadata, scrape_status: 'done') : record.update(scrape_status: 'error')
end

def determine_canonical_url(given_url)
  page = fetch_page(given_url)
  page ? fetch_canonical_url(page) || fetch_open_graph_url(page) || given_url : nil
end

def fetch_page(given_url)
  Nokogiri::HTML.parse(open(given_url))
rescue
  false
end

def fetch_canonical_url(doc)
  result = doc.xpath('//link[@rel="canonical"]/@href')
  result if result.present?
end

def fetch_open_graph_url(doc)
  property = doc.css("meta[property='og:url']")&.first
  property.attributes['content'].value if property.present?
end

def prepare_metadata(record)
  {
      title: 'Open Graph protocol',
      **record.attributes.symbolize_keys.slice(:id, :scrape_status),
      **record.metadata.symbolize_keys
  }
end
