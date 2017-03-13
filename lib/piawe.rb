require 'piawe/version'
require 'piawe/rule_set'
require 'role_playing'
require 'date'
require 'bigdecimal'


class Piawe

	include RolePlaying::Context

	def initialize( people_array, rules_array )
		@rules = Piawe::RuleSet.new rules_array
		@people = people_array.map { |person_hash| Person.played_by(person_hash) }
	end # initialize


	def report( report_date=Date.today )
		{
			report_date: report_date.strftime("%Y/%m/%d"),
			report_lines: @people.map { |person| @rules.report_line(person, report_date) }
		}
	end # method report



	role :Person do

		def weeks_since_injury(report_date)
			@weeks_since_injury ||= ( report_date - injury_date) / 7 
		end


		def injury_date
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


		def name
			self.has_key?("name") || (raise ArgumentError, "person_hash does not have a key of name: #{self.inspect}")
			self["name"] || (raise ArgumentError, "person_hash has a nil value for name key: #{self.inspect}")
			self["name"]
		end


		def hourly_rate
			get_decimal "hourlyRate"
		end


		def overtime_rate
			get_decimal "overtimeRate"
		end


		def normal_hours
			get_decimal "normalHours"
		end


		def overtime_hours
			get_decimal "overtimeHours"
		end


		def get_decimal(key)
			self.has_key?(key) || (raise ArgumentError, "person_hash does not have a key of #{key}: #{self.inspect}")
			self[key].is_a?(Numeric) || (raise ArgumentError, "person_hash has a non-numeric value for #{key} key: #{self.inspect}")
			BigDecimal.new self[key], 15
		end


	end


end # class Piawe