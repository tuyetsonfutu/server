class SitesController < ApplicationController
  def index
    @sites = Site.all
    #render xml: => @sites.to_xml(:root => 'sites')
    render :xml => @sites.to_xml(:root => 'sites')
  end
  def test_site
    @sites = Site.all
    render :xml => @sites.to_xml
    #render xml: @sites.to_xml(root: "sites") 
  end
end
