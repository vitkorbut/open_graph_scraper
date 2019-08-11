class CanonicalUrl < ActiveRecord::Base
  validates :canonical_url, presence: true, uniqueness: true
end
