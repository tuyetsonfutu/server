class PapersController < ApplicationController
  def index
    site = params['code'].split(':').first
    category = params['code'].split(':').last
    site_category = SiteCategory.where(:site_id => site,:category_id => category).last
    @paper = Paper.find(:site_category_id => site_category.id )
    render xml: @paper
  end
end
