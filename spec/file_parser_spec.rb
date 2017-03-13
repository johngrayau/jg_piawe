require 'spec_helper'

describe Piawe::FileParser do

	let (:people_file_name) do File.expand_path('../files/people.json', __FILE__); end

	let (:rules_file_name)  do File.expand_path('../files/rules_fixed.json', __FILE__); end

	let (:empty_file_name) do File.expand_path('../files/empty.json', __FILE__); end

	let (:file_parser_invalid_report_date_format)     do Piawe::FileParser.new( people_file_name, rules_file_name, "foo" ); end

	let (:file_parser_invalid_report_date)     				do Piawe::FileParser.new( people_file_name, rules_file_name, "2017/01/50" ); end

	let (:file_parser_invalid_people_filename) 				do Piawe::FileParser.new( "foo", rules_file_name, "2017/01/01" ); end

	let (:file_parser_invalid_rules_filename)  				do Piawe::FileParser.new( people_file_name, "foo", "2017/01/01" ); end

	let (:file_parser_empty_people_file)       				do Piawe::FileParser.new( empty_file_name, rules_file_name, "2017/01/01" ); end

	let (:file_parser_empty_rules_file)       				do Piawe::FileParser.new( people_file_name, empty_file_name, "2017/01/01" ); end

	#

	let (:valid_file_parser)	do Piawe::FileParser.new( people_file_name, rules_file_name, "2017/03/01" ); end

	let (:report) 						do valid_file_parser.report; end


	context "with an invalid date format" do
		it "should raise an exception" do expect { file_parser_invalid_report_date_format.report }.to raise_error(ArgumentError, /report_date_string was not in YYYY\/MM\/DD format/); end
	end


	context "with an invalid date" do
		it "should raise an exception" do expect { file_parser_invalid_report_date.report }.to raise_error(ArgumentError, /report_date_string does not represent a valid date: 2017\/01\/50/); end
	end


	context "with an invalid date" do
		it "should raise an exception" do expect { file_parser_invalid_report_date.report }.to raise_error(ArgumentError, /report_date_string does not represent a valid date: 2017\/01\/50/); end
	end


	context "with an invalid people_file_name" do
		it "should raise an exception" do expect { file_parser_invalid_people_filename.report }.to raise_error(ArgumentError, /Could not find file foo/); end
	end


	context "with an invalid rules_file_name" do
		it "should raise an exception" do expect { file_parser_invalid_rules_filename.report }.to raise_error(ArgumentError, /Could not find file foo/); end
	end


	context "with an empty people_file_name" do
		it "should raise an exception" do expect { file_parser_empty_people_file.report }.to raise_error(ArgumentError, /people hash did not contain a people key/); end
	end


	context "with an empty rules_file_name" do
		it "should raise an exception" do expect { file_parser_empty_rules_file.report }.to raise_error(ArgumentError, /rules hash did not contain a rules key/); end
	end

	context "with a valid file parser" do
		it "should contain valid JSON" 								do expect( JSON.parse(report) ).to be_kind_of(Hash); end
		it "should contain a piawe report" 						do expect( JSON.parse(report)["piawe_report"] ).to be_kind_of(Hash); end
		it "should have a report_date" 								do expect( JSON.parse(report)["piawe_report"]["report_date"] ).to eql("2017/03/01"); end
		it "should have the correct number of lines" 	do expect( JSON.parse(report)["piawe_report"]["report_lines"].size ).to eql(4); end
	end

end

# end
