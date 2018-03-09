{ helpers = "yes" }

function load_helpers() {
	data["page_title"] = page_title()
	data["section_title"] = section_title()
	data["next_section"] = next_section()
	data["previous_section"] = previous_section()
}

function page_title() {
	if (data["article_title"]) {
		return "<h1 class=\"site-content-title\">&hellip; " data["article_title"] "</h1>"
	} else {
		return ""
	}
}

function section_title() {
	if (data["article_section"]) {
		return "<h1 class=\"site-content-subtitle\">" data["article_section"] "</h1>"
	} else {
		return ""
	}
}

function next_section() {
	if (data["next_link"]) {
		return "<a href=\"" data["next_link"] "\">Next: " data["next_text"] " &rarr;</a>"
	} else {
		return ""
	}
}
function previous_section() {
	if (data["previous_link"]) {
		return "<a href=\"" data["previous_link"] "\">&larr; Previous: " data["previous_text"] "</a>"
	} else {
		return ""
	}
}
