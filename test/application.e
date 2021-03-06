note
	description: "HAL application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit

	SHARED_EJSON

create
	make

feature {NONE} -- Initialization

	make
		local
--			hlink : LINK
--			hresource : RESOURCE
			order: ORDER
			js_cc: JSON_CUSTOMER_CONVERTER
			js_ic: JSON_ITEM_CONVERTER
			js_li: JSON_LINE_ITEM_CONVERTER
			js_oc: JSON_ORDER_CONVERTER
		do
			create file_reader
--			test_json_min
--			test_json_hal
--			test_json_link
--			test_hal
--			test_item_line_item
			test_order
		end

	test_order
		local
			js_ic: JSON_ITEM_CONVERTER
			js_li: JSON_LINE_ITEM_CONVERTER
			js_cc: JSON_CUSTOMER_CONVERTER
			js_oc: JSON_ORDER_CONVERTER
			l_item: ITEM
			line: LINE_ITEM
			l_cust: CUSTOMER
			l_order: ORDER
		do
			create js_ic.make
			create js_li.make
			create js_oc.make
			create js_cc.make
			json.add_converter (js_ic)
			json.add_converter (js_li)
			json.add_converter (js_oc)
			json.add_converter (js_cc)
			create line.make ("basket")
			create l_item.make ("ABCD123", 2, 9.5)
			line.add_item (l_item)
			create l_item.make ("GFZ111", 1, 11)
			line.add_item (l_item)
			create l_cust.make ("Javier", "test@hal.com")
			create l_order.make ("test", "USD", "Placed", l_cust)
			l_order.add_item (l_item)
			if attached {JSON_VALUE} json.value (l_order) as jv then
				print (jv.representation)
			end
		end

	test_item_line_item
		local
			js_ic: JSON_ITEM_CONVERTER
			js_li: JSON_LINE_ITEM_CONVERTER
			l_item: ITEM
			line: LINE_ITEM
		do
			create js_ic.make
			create js_li.make
			json.add_converter (js_ic)
			json.add_converter (js_li)
			create line.make ("basket")
			create l_item.make ("ABCD123", 2, 9.5)
			line.add_item (l_item)
			create l_item.make ("GFZ111", 1, 11)
			line.add_item (l_item)
			if attached {JSON_VALUE} json.value (line) as jv then
				print (jv.representation)
			end
		end

	test_hal
		local
			hal: JSON_HAL_RESOURCE_CONVERTER
		do
			create hal.make
			json.add_converter (hal)
			if attached json_file_from ("hal_example.json") as json_file then
				if attached {JSON_OBJECT} json_value_from_file (json_file) as jo then
					if attached {HAL_RESOURCE} json.object (jo, "HAL_RESOURCE") as r then
						print (r.out)
						if attached json.value (r) as jv then
							print (jv.representation)
						end
						if attached r.self as l_link then
							print (l_link.out)
						end
						if attached r.links_keys as lk then
							print (lk.out)
						end
						if attached r.links_by_key ("next") as ln then
							check
								ln.rel ~ "next"
							end
						end
					end
				end
			end
		end

	test_json_hal
			--
		do
			if attached json_file_from ("hal_example.json") as json_file then
				if attached {JSON_OBJECT} json_value_from_file (json_file) as jo then
					print (jo.representation)
				end
			end
		end

--	test_json_link
--			--
--		local
--			r : HASH_TABLE [LINK, STRING]
--		do
--			if attached json_file_from ("hal_multi_links.json") as json_file then
--				if attached {JSON_OBJECT} json_value_from_file (json_file) as jo then
--					if attached {JSON_OBJECT} jo.item ("_links") as j_links then
--						r := from_json_link (j_links)
--						print (r.out)
--					end
--				end
--			end
--		end

	test_json_min
			--
		do
			if attached json_file_from ("min_hal.json") as json_file then
				if attached {JSON_OBJECT} json_value_from_file (json_file) as jo then
					print (jo.representation)
				end
			end
		end

feature -- Implementation

	file_reader: JSON_FILE_READER

	json_file_from (fn: STRING): detachable STRING
		do
			Result := file_reader.read_json_from (fn)
		ensure
			Result /= Void
		end

	new_json_parser (a_string: STRING): JSON_PARSER
		do
			create Result.make_parser (a_string)
		end

	json_value_from_file (json_file: STRING): detachable JSON_VALUE
		local
			p: like new_json_parser
		do
			p := new_json_parser (json_file)
			Result := p.parse_json
			check
				json_is_parsed: p.is_parsed
			end
		end

end
