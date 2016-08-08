class Launch < ApplicationRecord

  def self.scrape_launches
    doc = Nokogiri::HTML(open('https://spaceflightnow.com/launch-schedule/'))

    data = {}

    data[:missions] = doc.css("div.datename span.mission").map{|elem| elem.content}

    data[:dates] = doc.css("div.datename span.launchdate").map{|elem| elem.content}

    data[:windows] = doc.css("div.missiondata").map{|elem| /\(([^)]+)\)/.match(elem.content).to_a[1]}

    data[:sites] = doc.css("div.missiondata").map{|elem| elem.content.match(/(?<=Launch site: ).*/).to_s}

    data[:descriptions] = doc.css("div.missdescrip").map{|elem| elem.content}

    (0..data[:missions].size-1).each do |index|
      launch = Launch.new
      data.keys.each {|key| launch.send("#{key[0..-2]}=", data[key][index])}
      launch.save
    end

  end

  def self.launches_this_week
    launches_this_month.select{|launch| launch.this_week?}
  end

  def self.launches_this_month
    Launch.all.select{|launch| launch.this_month?}
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
