{ helpers = "yes" }

function load_helpers() {
	data["page_title"] = page_title()
}

function page_title(title) {
	if (data["article_title"]) {
		title = "&hellip; " data["article_title"]
	} else {
		title = ""
	}
	return title
}
