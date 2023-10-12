-- First sample: select all parts named "Test"
function change_selection(selection)
	add_parts_with_attribute(selection, "article_no")
end

function add_parts_with_attribute(selection, attribute, value)
	for part in pytha.enumerate_parts() do
		if part:get_element_attribute(attribute) ~= "" and part:get_element_attribute(attribute) ~= nil  then
			table.insert(selection, part)
		end
	end
end

