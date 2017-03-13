require 'piawe/version'
require 'piawe/rule_set'
require 'piawe/file_parser'
require 'role_playing'
require 'date'
require 'bigdecimal'

# Class to encapsulate PIAWE report generation
class Piawe

	include RolePlaying::Context

	# Create a new Piawe instance to generate reports for a particular set of people and rules
	# 
  #
  # ==== Parameters
  #
  # * +people_array+ - An array of people hashes
  #
  # * +rules_array+ - An array of rule hashes
  #
  # ==== People Hash
  #
  # A people hash it a Ruby hash that has has the following format:
  #
	#		{"people": [
	#		    {"name": "Ebony Boycott", "hourlyRate": 75.0030, "overtimeRate": 150.0000, "normalHours": 35.0, "overtimeHours": 7.3, "injuryDate": "2016/05/01" },
	#		    {"name": "Geoff Rainford-Brent", "hourlyRate": 30.1234, "overtimeRate": 60.3456, "normalHours": 25.0, "overtimeHours": 10.7, "injuryDate": "2016/08/04" },
	#		    {"name": "Meg Gillespie", "hourlyRate": 50.0000, "overtimeRate": 100.0000, "normalHours": 37.5, "overtimeHours": 0.0, "injuryDate": "2015/12/31" },
	#		    {"name": "Jason Lanning", "hourlyRate": 40.0055, "overtimeRate": 90.9876, "normalHours": 40.0, "overtimeHours": 12.4, "injuryDate": "2013/01/01" }
	#		]}
	#
	# * name - The person's name.
	#
	# * hourlyRate - The person's hourly rate of pay, calculated according to PIAWE rules.
	#
	# * overtimeRate - The person's overtime rate of pay, calculated according to PIAWE rules.
	#
	# * normalHours - The person's normal weekly hours, calculated according to PIAWE rules.
	#
	# * overtimeHours - The person's normal weekly overtime hours, calculated according to PIAWE rules.
	#
	# * injuryDate - The date of the injury that caused the person to cease work.
	#
  # ==== Rule Hash
  #
  # A rule hash it a Ruby hash that has has the following format:
  #
	#   {"rules":[
	#     {"applicableWeeks": "1-26", "percentagePayable": 90, "overtimeIncluded": true},
	#     {"applicableWeeks": "27-52", "percentagePayable": 80, "overtimeIncluded": true},
	#     {"applicableWeeks": "53-79", "percentagePayable": 70, "overtimeIncluded": true},
	#     {"applicableWeeks": "80-104", "percentagePayable": 60, "overtimeIncluded": false},
	#     {"applicableWeeks": "105+", "percentagePayable": 10, "overtimeIncluded": false}
	#   ]}
	#
	# * applicableWeeks - A String that indicates the range of injury weeks during which the rule applies - Week 1 starts at the day of the injury, and Week 2 starts on the 7th day after the injury, and so on.  It can have two formats: either a start week and end week joined by a dash, or a start week followed by a plus sign, which indicates the rule should apply to all later weeks as well. The first rule must have a start week of 1, the last rule must use the plus sign syntax, and all intervening rules must have a start week that is one greater than the end week of the preceeding rule.
	#
	# * percentagePayable - A Numeric that indicates the percentage of Average Weekly Earnings that are paid when this rule applies.
	#
	# * overtimeIncluded - A TrueClass or FalseClass that indicates whether overtime earnings should be considered part of Average Weekly Earnings when this rule applies.
	def initialize( people_array, rules_array )
		@rules = Piawe::RuleSet.new rules_array
		@people = people_array.map { |person_hash| Person.played_by(person_hash) }
	end # initialize


	# Generate a PIAWE report (Ruby Hash format) for the people and rules this Piawe instance encapsulates, as at the specified report date. 
  #
  # ==== Parameters
  #
  # * +report_date+ - The date for which the report should be generated. Defaults to the current date
  #
	def report( report_date=Date.today )
		{
			report_date: report_date.strftime("%Y/%m/%d"),
			report_lines: @people.map { |person| @rules.report_line(person, report_date) }
		}
	end # method report



	role :Person do

		def weeks_since_injury(report_date) # :nodoc:
			@weeks_since_injury ||= ( report_date - injury_date) / 7 
		end


		def injury_date # :nodoc:
			@injury_date ||= (
				self.has_key?("injuryDate") || (raise ArgumentError, "person_hash does not have a key of injuryDate: #{self.inspect}")
				/^\d{4}\/\d{2}\/\d{2}$/ =~ self["injuryDate"] || (raise ArgumentError, "injury date of #{self["injuryDate"]} is not in yyyy/mm/dd format: #{self.inspect}")
				result = nil
				begin
					result = Date.parse self["injuryDate"]
				rescue ArgumentError => ex
					raise ArgumentError, "person_hash has an invalidly formatted injuryDate key: #{self.inspect} }"
				end
				result <= Date.today || (raise ArgumentError, "person_hash has an injuryDate value that is in the future: #{self.inspect}")
				result
			)
		end


		def name # :nodoc:
			self.has_key?("name") || (raise ArgumentError, "person_hash does not have a key of name: #{self.inspect}")
			self["name"] || (raise ArgumentError, "person_hash has a nil value for name key: #{self.inspect}")
			self["name"]
		end


		def hourly_rate # :nodoc:
			get_decimal "hourlyRate"
		end


		def overtime_rate # :nodoc:
			get_decimal "overtimeRate"
		end


		def normal_hours # :nodoc:
			get_decimal "normalHours"
		end


		def overtime_hours # :nodoc:
			get_decimal "overtimeHours"
		end


		def get_decimal(key) # :nodoc:
			self.has_key?(key) || (raise ArgumentError, "person_hash does not have a key of #{key}: #{self.inspect}")
			self[key].is_a?(Numeric) || (raise ArgumentError, "person_hash has a non-numeric value for #{key} key: #{self.inspect}")
			BigDecimal.new self[key], 15
		end


	end


end # class Piawe