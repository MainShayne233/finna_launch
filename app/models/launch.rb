class Launch < ApplicationRecord



  def self.scrape_launches
    Launch.destroy_all

    doc = Nokogiri::HTML(open('https://spaceflightnow.com/launch-schedule/'))

    data = {
              missions: doc.css("div.datename span.mission").map{|elem| elem.content},
              dates: doc.css("div.datename span.launchdate").map{|elem| elem.content},
              windows: doc.css("div.missiondata").map{|elem| /\(([^)]+)\)/.match(elem.content).to_a[1]},
              sites: doc.css("div.missiondata").map{|elem| elem.content.match(/(?<=Launch site: ).*/).to_s},
              descriptions: doc.css("div.missdescrip").map{|elem| elem.content}
           }


    (0..data[:missions].size-1).each do |index|
      launch = Launch.new
      data.keys.each {|key| launch.send("#{key[0..-2]}=", data[key][index])}
      launch.save
    end

    launches = launches_this_week
    unless launches.empty?
      msg = "There #{launches.size > 1 ? "are #{launches.size} launches" : 'is one launch'} this week!\n\n"
      msg << launches.map{|launch| "#{launch.mission}\n#{launch.date}\n#{launch.window}"}.join("\n\n")
      # Twilio::Sms.message(8442422517, 3212929136, msg)
    end

  end

  def self.launches_this_week
    launches_this_month.select{|launch| launch.this_week?}
  end

  def self.launches_this_month
    local_launches.select{|launch| launch.this_month?}
  end

  def self.local_launches
    Launch.all.select{|launch| launch.site.downcase.include?('florida') }
  end


  def this_month?
    Time.now.strftime('%B').include? date.split(' ').first[0..-2]
  end



  def this_week?
    if day = date.match(/\d.*/)
      day.to_s.to_i - Time.now.strftime('%-d').to_i < 8
    end
  end
``
end
