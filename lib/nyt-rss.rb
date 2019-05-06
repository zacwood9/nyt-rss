require "httparty"
require "nokogiri"
require "net/http"
require "rack"
require "sinatra"
require "sinatra/reloader" if development?

module NYTRSS
  $feeds = {
    :arts => "http://www.nytimes.com/services/xml/rss/nyt/Arts.xml",
    :automobiles => "http://www.nytimes.com/services/xml/rss/nyt/Automobiles.xml",
    :books => "http://www.nytimes.com/services/xml/rss/nyt/Books.xml",
    :business => "http://www.nytimes.com/services/xml/rss/nyt/Business.xml",
    :circuits => "http://www.nytimes.com/services/xml/rss/nyt/Circuits.xml",
    :diningandwine => "http://www.nytimes.com/services/xml/rss/nyt/DiningandWine.xml",
    :opinion => "http://www.nytimes.com/services/xml/rss/nyt/Opinion.xml",
    :education => "http://www.nytimes.com/services/xml/rss/nyt/Education.xml",
    :fashionandstyle => "http://www.nytimes.com/services/xml/rss/nyt/FashionandStyle.xml",
    :health => "http://www.nytimes.com/services/xml/rss/nyt/Health.xml",
    :homeandgarden => "http://www.nytimes.com/services/xml/rss/nyt/HomeandGarden.xml",
    :international => "http://www.nytimes.com/services/xml/rss/nyt/International.xml",
    :magazine => "http://www.nytimes.com/services/xml/rss/nyt/Magazine.xml",
    :mediaandadvertising => "http://www.nytimes.com/services/xml/rss/nyt/MediaandAdvertising.xml",
    :pop_top => "http://www.nytimes.com/services/xml/rss/nyt/pop_top.xml",
    :movienews => "http://www.nytimes.com/services/xml/rss/nyt/MovieNews.xml",
    :movies => "http://www.nytimes.com/services/xml/rss/nyt/Movies.xml",
    :multimedia => "http://www.nytimes.com/services/xml/rss/nyt/Multimedia.xml",
    :national => "http://www.nytimes.com/services/xml/rss/nyt/National.xml",
    :nyregion => "http://www.nytimes.com/services/xml/rss/nyt/NYRegion.xml",
    :homepage => "http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml",
    :obituaries => "http://www.nytimes.com/services/xml/rss/nyt/Obituaries.xml",
    :poguesposts => "http://www.nytimes.com/services/xml/rss/nyt/PoguesPosts.xml",
    :realestate => "http://www.nytimes.com/services/xml/rss/nyt/RealEstate.xml",
    :science => "http://www.nytimes.com/services/xml/rss/nyt/Science.xml",
    :sports => "http://www.nytimes.com/services/xml/rss/nyt/Sports.xml",
    :technology => "http://www.nytimes.com/services/xml/rss/nyt/Technology.xml",
    :television => "http://www.nytimes.com/services/xml/rss/nyt/Television.xml",
    :theater => "http://www.nytimes.com/services/xml/rss/nyt/Theater.xml",
    :travel => "http://www.nytimes.com/services/xml/rss/nyt/Travel.xml",
    :washington => "http://www.nytimes.com/services/xml/rss/nyt/Washington.xml",
    :weekinreview => "http://www.nytimes.com/services/xml/rss/nyt/WeekinReview.xml",
  }
  
  class Feed
    def initialize(tag)
      link = $feeds[tag.to_sym]
      @xml_str = HTTParty.get(link).body
    end

    def all
      @xml_str
    end

    def by_author(name)
      xml = Nokogiri::XML(@xml_str)
      xml.xpath("//item").each do |node|
        node.unlink unless node.xpath("dc:creator").text.upcase.include?(name.upcase)
      end
      xml.to_xml
    end

    def authors
      Nokogiri::XML(@xml_str)
        .xpath("//dc:creator")
        .map    { |tag| tag.text }
        .reject { |text| text.empty? }
        .uniq
        .sort
    end
  end

  class App < Sinatra::Base    
    set :server, :puma

    get "/" do
      @sections = $feeds.map do |key, value|
        key.to_s
      end
      erb :index
    end
    
    get "/:section", provides: [:xml] do |section|
      sym = section.to_sym
      return bad_request if $feeds[sym].nil?
      feed = Feed.new(sym)
      feed.all
    end

    get "/:section/:author", provides: [:xml] do |section, author|
      sym = section.to_sym
      return bad_request if $feeds[sym].nil?
      feed = Feed.new(sym)
      feed.by_author(author)
    end

    private

    def bad_request
      [400, { "Content-Type" => "text/plain"}, ["bad request"]]
    end
  end
end

NYTRSS::App.run!




