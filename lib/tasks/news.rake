Dir[File.expand_path(File.dirname(__FILE__)) + '/../*.rb'].each {|file|require file}
namespace :news do
  desc "Crawler all news"
  task crawl: :environment do
    Reader.new.run
  end
end
