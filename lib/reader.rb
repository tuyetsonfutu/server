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
    @sites = ['Tienphong','Thanhnien','Vietnamnet','Nguoiduatin','Vnexpress','Ictnews','Cand','Bongdaplus']
    # Thanh niên, gamek, 24h 
  end
  
  def run
    @sites.each do |site_name|
      next if Site.where(:site_name => site_name).size > 0 
      base = @params[site_name]['base']
      site = Site.new(:site_name => site_name)
      site.url = base
      site.save
      begin
        doc = Nokogiri::HTML(open(@params[site_name]['rss_link']))
      rescue
        next
      end
      
      next if doc.blank?
      list = doc.xpath(@params[site_name]['list_link'])
      list_category = doc.xpath(@params[site_name]['category'])
      list.each_with_index do |link,i|
        url = base + link['href']
        url = link['href'] if link['href'].to_s.include? 'http'
        open(url) do |rss|
          rss = open(url).read
          feed = RSS::Parser.parse(rss,false)
          #puts "Title: #{feed.channel.title}"
          name = ""
          if !list_category.present?
            name = feed.channel.title
            @params[site_name]['remove_name'].each do |rmn|
              name = name.gsub(rmn,'')
            end
          else
            name = list_category[i].text.gsub('+>','').strip
          end
          category = Category.find_or_create_by(:title => name)
          feed.items.each do |est|
            est.description.split(' ').each do  |et|
              category.image = et.gsub('src=','').gsub('"','').gsub('&quot;','').gsub('.ashx','').gsub('?width=80','').gsub('?w=220','') if et.include? 'src'
            end
            break if !category.image.nil?
          end
          category.image = 'http://media.tinmoi.vn/2011/12/15/50_7_1323913837_36_images812661_118bao_634171567843600000.jpg' if category.image.nil?
          category.save
          site_category = SiteCategory.new(:site_id => site.id.to_s)
          site_category.category_id = category.id.to_s
          site_category.save
          feed.items.each do |item|
            paper = Nokogiri::HTML(open(item.link.strip)) rescue next 
            content = ''
            @params[site_name]['content'].each do |content_path|
              content = paper.xpath(content_path) if  paper.present?
              break if !content.blank?
            end
            if !content.blank?
              content_paper = Paper.new(:site_category_id => site_category.id.to_s)
              content_paper.url = item.link.strip
              content_paper.title = item.title.gsub('"','').strip
              content.search('script').remove
              content.search('img')
              content.search('section').remove
              content_paper.content = content.to_s
              content_paper.save
            end
          end 
        end
      end
    end
  end
end