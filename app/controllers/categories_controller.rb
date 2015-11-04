class CategoriesController < ApplicationController
  def index 
    site_id = params['site']
    site_categories = SiteCategory.where(:site_id => site_id)
    @cats = []
    site_categories.each do |st|
      @cats.push  Category.find(st.category_id.to_s)
    end
    @cats = Category.all if  @cats.blank?
    render xml: @cats
  end
end
