require 'csv'

class DataFile < ActiveRecord::Base

  def self.processActivities(upload, user_id)
    data = upload['datafile'].read

    lines = CSV.parse(data)

    added = 0

    lines.each do |line|
      a = Activity.new
      a.user_id = user_id
      a.activity_type_id = 1
      a.date = Date.parse(line[0].strip)
      a.description = line[1].strip
      a.duration_hours = line[2].strip.to_f
      a.distance_miles = 0
      added = added + 1 if a.save
    end

    added
  end

  def self.processFitnessSamples(upload)
  end
end
