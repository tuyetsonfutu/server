require 'rss'
require 'open-uri'
require 'nokogiri'
require 'mongoid'
require 'byebug'
require 'yaml'
#Dir[File.expand_path(File.dirname(__FILE__)) + '/../app/models/*.rb'].each {|file|require file}
Dir[File.expand_path(File.dirname(__FILE__)) + '/../config/mongoid.yml'].each {|file| Mongoid.load!(file, :development) }
class Reader
  
  def initialize
    @params = YAML.load(File.read File.dirname(__FILE__)+ '/news/xpaths.yml')
    @sites = ['vietnamnet','vnexpress']
  end
  
  def run
    @sites.each do |site_name|
      base = @params[site_name]['base']
      site = Site.new(:site_name => site_name)
      site.url = base
      site.save
      doc = Nokogiri::HTML(open(@params[site_name]['rss_link']))
      list = doc.xpath(@params[site_name]['list_link'])
      list.each do |link|
        url = base + link['href']
        open(url) do |rss|
          rss = open(url).read
          feed = RSS::Parser.parse(rss,false)
          puts "Title: #{feed.channel.title}"
          name = feed.channel.title.gsub(@params[site_name]['remove_name'],'')
          category = Category.find_or_create_by(:title => name)
          category.save
          site_category = SiteCategory.new(:site_id => site.id.to_s)
          site_category.category_id = category.id.to_s
          site_category.save
          feed.items.each do |item|
            paper = Nokogiri::HTML(open(item.link.strip)) rescue ''
            content = paper.xpath(@params[site_name]['content']) if  paper.present?
            if content.present?
              content_paper = Paper.new(:site_category_id => site_category.id )
              content_paper.content = content.to_s
              content_paper.save
            end
          end 
        end
      end
    end
  end
  
end