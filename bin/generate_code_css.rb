require "rouge"

path = File.join(File.dirname(__FILE__), "..", "site", "_", "css", "code.css")

File.open(path, "w") do |f|
	f.write Rouge::Themes::Base16::Solarized.render(scope: ".highlight")
end
