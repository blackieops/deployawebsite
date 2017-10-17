require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

Extensions = {
	fenced_code_blocks: true,
	space_after_headers: true,
	disable_indented_code_blocks: true
}.freeze

class CustomRenderer < Redcarpet::Render::HTML
	include Rouge::Plugins::Redcarpet
end

puts Redcarpet::Markdown.new(CustomRenderer.new, Extensions).render($stdin.read)
