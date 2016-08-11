require 'nokogiri'
require 'open-uri'
require 'twilio'

Twilio.connect(ENV['TWILIO_SID'], ENV['TWILIO_AUTH_TOKEN'])
TWILIO_NUM = ENV['TWILIO_NUM']
MY_NUM = ENV['MY_NUM']

class Launch

  attr_accessor :mission, :date, :window, :site, :description

  def self.scrape_launches

    doc = Nokogiri::HTML(open('https://spaceflightnow.com/launch-schedule/'))

    data = {
        missions: doc.css("div.datename span.mission").map{|elem| elem.content},
        dates: doc.css("div.datename span.launchdate").map{|elem| elem.content},
        windows: doc.css("div.missiondata").map{|elem| /\(([^)]+)\)/.match(elem.content).to_a[1]},
        sites: doc.css("div.missiondata").map{|elem| elem.content.match(/(?<=Launch site: ).*/).to_s},
        descriptions: doc.css("div.missdescrip").map{|elem| elem.content}
    }

    launches = []
    (0..data[:missions].size-1).each do |index|
      launch = Launch.new
      data.keys.each {|key| launch.send("#{key[0..-2]}=", data[key][index])}
      launches << launch
    end


    launches = launches_this_week launches
    unless launches.empty?
      msg = "There #{launches.size > 1 ? "are #{launches.size} launches" : 'is one launch'} this week!\n"
      msg << launches.map{|launch| "#{launch.mission}\n#{launch.date}\n#{launch.window}"}.join("\n\n")
      puts msg
      puts Twilio::Sms.message(TWILIO_NUM, MY_NUM, msg.gsub('•', ''))
    end

  end

  def self.launches_this_week launches
    launches_this_month(launches).select{|launch| launch.this_week?}
  end

  def self.launches_this_month launches
    local_launches(launches).select{|launch| launch.this_month?}
  end

  def self.local_launches launches
    launches.select{|launch| launch.site.downcase.include?('florida') }
  end


  def this_month?
    Time.now.strftime('%B').include? date.split(' ').first[0..-2]
  end



  def this_week?
    if day = date.match(/\d.*/)
      day.to_s.to_i - Time.now.strftime('%-d').to_i < 8
    end
  end
end

day = 0

while true
  sleep 5
  Launch.scrape_launches
end
