class SiteCategory
  include Mongoid::Document
  field :name
  field :site_id
  field :category_id
end