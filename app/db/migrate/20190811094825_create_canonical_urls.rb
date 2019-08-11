class CreateCanonicalUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :canonical_urls do |t|
      t.string :canonical_url, null: false
      t.string :scrape_status, null: false, default: 'not_scraped'
      t.json :metadata, default: {}

      # t.timestamps, null: false
    end

    add_index :canonical_urls, :canonical_url, unique: true
  end
end
