require 'piawe/version'
require 'role_playing'

include RolePlaying::Context

class Piawe

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
				/^\d{4}\/\d{2}\/\d{2}$/ =~ self["injuryDate"] || (raise ArgumentError, "injury date of #{self["injuryDate"]} is not in yyyy/mm/dd format")
				Date.parse self["injuryDate"]
			)
		end


		def name
			self.has_key?("name") || (raise ArgumentError, "person_hash does not have an name key: #{self.inspect}")
			self["name"]
		end


		def hourly_rate
			self.has_key?("hourlyRate") || (raise ArgumentError, "person_hash does not have an hourlyRate key: #{self.inspect}")
			self["hourlyRate"]
		end


		def overtime_rate
			self.has_key?("overtimeRate") || (raise ArgumentError, "person_hash does not have an overtimeRate key: #{self.inspect}")
			self["overtimeRate"]
		end


	end


end # class Piawe