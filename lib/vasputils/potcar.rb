#
# Class for dealing with POTCAR.
#
module Potcar
  def self.load_file(file)
    results = {}
    results[:name] = file

    elements = Array.new
    File.open( file, "r" ).each do |line|
      if line =~ /VRHFIN\s*=\s*([A-Za-z]*)/
        elements << $1
      end
    end
    results[:elements] = elements
    results
  end
end
