require "rouge"

path = File.join(File.dirname(__FILE__), "..", "assets", "sass", "components", "_syntax.scss")

File.open(path, "w") do |f|
	f.write Rouge::Themes::Base16::Solarized.render(scope: ".highlight")
end
