require 'piawe/version'
require 'rule_set'
require 'role_playing'
require 'date'
require 'bigdecimal'


class Piawe

	include RolePlaying::Context

	def initialize( people_array, rules_array, report_date=Date.today )
		@rules = RuleSet.new rules_array
		@people = people_array.map { |person_hash| Person.played_by(person_hash) }
		@report_date = report_date
	end # initialize


	def report
		{
			payment_report: {
				report_date: @report_date,
				report_lines: @people.map { |person| @rules.payment_report(person, @report_date) }
			}
		}
	end # method report



	role :Person do

		def weeks_since_injury(report_date)
			@weeks_since_injury ||= ( report_date - injury_date) / 7 
		end


		def injury_date
			@injury_date ||= (
				self.has_key?("injuryDate") || (raise ArgumentError, "person_hash does not have an injuryDate key: #{self.inspect}")
				/^\d{4}\/\d{2}\/\d{2}$/ =~ self["injuryDate"] || (raise ArgumentError, "injury date of #{self["injuryDate"]} is not in yyyy/mm/dd format for person #{self.name}")
				result = nil
				begin
					result = Date.parse self["injuryDate"]
				rescue ArgumentError => ex
					raise "injuryDate value for person #{self.name} was not a valid date number - value was #{ self["injuryDate"] }"
				end
				result
			)
		end


		def name
			self.has_key?("name") || (raise ArgumentError, "person_hash does not have an name key: #{self.inspect}")
			self["name"]
		end


		def hourly_rate
			get_decimal "hourlyRate"
		end


		def overtime_rate
			get_decimal "overtimeRate"
		end


		def normal_hours
			get_decimal "normal_hours"
		end


		def overtime_hours
			get_decimal "overtime_hours"
		end


		def get_decimal(key)
			self.has_key?(key) || (raise ArgumentError, "person_hash does not have an #{key} key: #{self.inspect}")
			/^[+-]?\d+(\.\d+)?$/ =~ self[key] || (raise ArgumentError, "#{key} value for person #{self.name} was not a valid Decimal number - value was #{ self[key] }" )
			BigDecimal.new self[key].strip
		end


	end


end # class Piawe