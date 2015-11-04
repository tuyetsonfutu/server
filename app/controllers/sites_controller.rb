class SitesController < ApplicationController
  def index
    @sites = Site.all
    render xml: @sites
  end
end
