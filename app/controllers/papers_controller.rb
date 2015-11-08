class PapersController < ApplicationController
  def index
    site = params['code'].split(':').first
    category = params['code'].split(':').last
    site_category = SiteCategory.where(:site_id => site,:category_id => category).last
    @paper = Paper.where(:site_category_id => (site_category.id).to_s)
    render xml: @paper
  end
end
