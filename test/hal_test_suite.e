note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	HAL_TEST_SUITE

inherit
	SHARED_EJSON
			rename default_create as default_create_ejson
		end
	EQA_TEST_SET
		redefine
			on_prepare
		select
			default_create
		end

feature {NONE} -- Events

	on_prepare
			-- <Precursor>
		do
			create file_reader
		end

feature -- Test routines

	test_min_hal
    		--
		local
			parse_json: like new_json_parser
			hal: JSON_HAL_RESOURCE_CONVERTER
		do
			create hal.make
			json.add_converter (hal)
			if attached json_file_from ("min_hal.json") as json_file then
				parse_json := new_json_parser (json_file)
				if attached parse_json.parse_json as jv then
					if attached {RESOURCE} json.object (jv, "RESOURCE") as l_r then
						assert("Is Valid Resource", l_r.is_valid_resource = True)
					end
				end
			end
		end


feature {NONE} -- Implementation

	json_value: detachable JSON_VALUE

	file_reader: JSON_FILE_READER

   	json_file_from (fn: STRING): detachable STRING
		do
			Result := file_reader.read_json_from (test_dir + fn)
			assert ("File contains json data", Result /= Void)
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
			check json_is_parsed: p.is_parsed end
		end

	test_dir: STRING
		local
			i: INTEGER
		do
			Result := (create {EXECUTION_ENVIRONMENT}).current_working_directory
			Result.append_character ((create {OPERATING_ENVIRONMENT}).directory_separator)
				-- The should looks like
				-- ..json\test\autotest\test_suite\EIFGENs\test_suite\Testing\execution\TEST_JSON_SUITE.test_json_fail1\..\..\..\..\..\fail1.json
			from
				i := 5
			until
				i = 0
			loop
				Result.append_character ('.')
				Result.append_character ('.')
				Result.append_character ((create {OPERATING_ENVIRONMENT}).directory_separator)
				i := i - 1
			end
		end

end


