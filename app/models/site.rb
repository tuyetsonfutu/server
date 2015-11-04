class Site
  include Mongoid::Document
  field :site_name
  field :url
  field :description
end