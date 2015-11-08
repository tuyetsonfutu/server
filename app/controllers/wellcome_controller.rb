class WellcomeController < ApplicationController
  def index
    @sites = Site.all
    @categories = Category.all
    @site_categories = SiteCategory.all
  end
end
