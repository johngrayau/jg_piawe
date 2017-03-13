# Class to read people and rules files and convert them into a PIAWE report
class Piawe::FileParser

	# Create a new FileParser to generate a PIAWE report from files
	# 
  #
  # ==== Parameters
  #
  # * +people_file_name+ - Fully qualified path of the people file
  # * +rules_file_name+ - Fully qualified path of the rules file
  # * +report_date_string+ - Report date to use, in YYYY/MM/DD format
	def initialize( people_file_name, rules_file_name, report_date_string )
		@people_file_name = people_file_name
		@rules_file_name = rules_file_name
		@report_date_string = report_date_string
	end

	# Generate a JSON hash containing the PIAWE report
	def report
		JSON.pretty_generate( { piawe_report: Piawe.new( people_array, rules_array ).report( report_date ) } )
	end

private

	def people_array
		people_hash["people"] || (raise ArgumentError, "people hash did not contain a people key!")
	end


	def people_hash
		JSON.parse people_file.read
	end


	def people_file
		File.exist?(@people_file_name) ? File.new(@people_file_name) : (raise ArgumentError, "Could not find file #{@people_file_name}")
	end


	def rules_array
		rules_hash["rules"] || (raise ArgumentError, "rules hash did not contain a rules key")
	end


	def rules_hash
		JSON.parse rules_file.read
	end


	def rules_file
		File.exist?(@rules_file_name) ? File.new(@rules_file_name) : (raise ArgumentError, "Could not find file #{@rules_file_name}")
	end


	def report_date
		/^(?<yyyy>\d{4})\/(?<mm>\d{2})\/(?<dd>\d{2})$/ =~ @report_date_string || (raise ArgumentError, "report_date_string was not in YYYY/MM/DD format")
		result = nil
		begin
			result = Date.new(yyyy.to_i, mm.to_i, dd.to_i)
		rescue ArgumentError => ex
			raise ArgumentError, "report_date_string does not represent a valid date: #{@report_date_string}"
		end
		result
	end

end