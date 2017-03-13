require 'bigdecimal'
require 'role_playing'

# Class to encapsulate a set of PIAWE payment rules
class Piawe::RuleSet

	include RolePlaying::Context


	# Create a new RuleSet to represent the rules contained in a rules array
	# 
  #
  # ==== Parameters
  #
  # * +rules_array+ - An array of rule hashes
  #
  # ==== Rule Hash
  #
  # A rule hash it a Ruby hash that has has the following format:
  #
	#   {"rules":[
	#     {"applicableWeeks": "1-26", "percentagePayable": 90, "overtimeIncluded": true},
	#     {"applicableWeeks": "26-52", "percentagePayable": 80, "overtimeIncluded": true},
	#     {"applicableWeeks": "53-79", "percentagePayable": 70, "overtimeIncluded": true},
	#     {"applicableWeeks": "80-104", "percentagePayable": 60, "overtimeIncluded": false},
	#     {"applicableWeeks": "104+", "percentagePayable": 10, "overtimeIncluded": false}
	#   ]}
	#
	# * applicableWeeks - A String that indicates the range of injury weeks during which the rule applies - Week 1 starts at the day of the injury, and Week 2 starts on the 7th day after the injury, and so on.  It can have two formats: either a start week and end week joined by a dash, or a start week followed by a plus sign, which indicates the rule should apply to all later weeks as well. The first rule must have a start week of 1, the last rule must use the plus sign syntax, and all intervening rules must have a start week that is one greater than the end week of the preceeding rule.
	#
	# * percentagePayable - A Numeric that indicates the percentage of Average Weekly Earnings that are paid when this rule applies.
	#
	# * overtimeIncluded - A TrueClass or FalseClass that indicates whether overtime earnings should be considered part of Average Weekly Earnings when this rule applies.



	def initialize(rules_array)
		rules_array && rules_array.is_a?(Array) || (raise ArgumentError, "rules array is required - got #{rules_array.inspect}")
		rules_array.size > 0 || (raise ArgumentError, "rules array must contain at least one entry")
		rules_array.each do |rule_hash|
			add(Rule.played_by rule_hash)
		end
		rules[-1].end_week.nil? || (raise ArgumentError, "last rule must have a terminating + sign")
	end


	def report_line(person, report_date)
		rules.each do |rule|
			return rule.report_line( person, report_date ) if rule.matches?( person.weeks_since_injury( report_date ) ) 
		end # each rule
		# this should not be possible - but putting this here defensively...
		raise "APPLICATION BUG - A RuleSet EXISTS THAT DOES NOT COVER ALL POSSIBLE DATES!! (Date was #{report_date.strftime('%Y/%m/%d')}, person was #{person.inspect})"
	end # method payment_report





	private


		def add(rule)
			# check consistency of rule dates
			(rule.end_week.nil? || rule.end_week > rule.start_week) || (raise ArgumentError, "rule #{rules.size + 1} has an end week of #{rule.end_week} that is not later than it's start week of #{rule.start_week}")
			if rules[-1] # we have existing rules, check we are consistent
				rules[-1].end_week || (raise ArgumentError, "rule #{rules.size} has a terminating + sign, and should have been the last rule, however there was a subsequent rule: #{rule.inspect}")
				rule.start_week == rules[-1].end_week + 1 || (raise ArgumentError, "rule #{rules.size} ends at week #{rules[-1].end_week} but rule #{rules.size + 1} starts at week #{rule.start_week} - each rule should start one week after the prior rule ends")
			else # this should be the first rule - check it's start date
				1 == rule.start_week || (raise ArgumentError, "rule 1 should start at week 1, but starts at week #{rule.start_week}")
			end # if we have existing rules
			rules << rule
		end # method add


		def rules 
			@rules ||= []
		end




		# role to be added to a rule hash
		role :Rule do

			def start_week
				@start_week ||= (
					/(?<starting_week>\d+)[+-]/ =~ applicable_weeks
					starting_week.to_i
				)
			end 


			def end_week
				@end_week ||= if /\+$/ =~ applicable_weeks
												nil
											else
												( /\d*\-(?<ending_week>\d+)$/ =~ applicable_weeks ) || (raise ArgumentError, "invalid applicableWeeks value: #{applicable_weeks}")
												ending_week.to_i
											end # if trailing + sign
			end


			def applicable_weeks
				@applicable_weeks ||= (
					self.has_key?("applicableWeeks") || (raise ArgumentError, "rule hash did not have an applicableWeeks key: #{self.inspect}")
					/(^\d+\-\d+$)|(^\d+\+$)/ =~ self["applicableWeeks"] || (raise ArgumentError, "applicableWeeks key is not in valid format")
					self["applicableWeeks"]
				)
			end


			def percentage_payable
				self.has_key?("percentagePayable") || (raise ArgumentError, "rule_hash does not have a percentagePayable key: #{self.inspect}")
				self["percentagePayable"].is_a?(Numeric) || (raise ArgumentError, "rule_hash has a non-numeric value for percentagePayable key: #{self['percentagePayable']}")
				BigDecimal.new self["percentagePayable"]
			end


			def overtime_included
				self.has_key?("overtimeIncluded") || (raise ArgumentError, "rule_hash does not have an overtimeIncluded key: #{self.inspect}")
				( self["overtimeIncluded"].is_a?(TrueClass) || self["overtimeIncluded"].is_a?(FalseClass) )  || (raise ArgumentError, "overtimeIncluded value was not a boolean true or false - value was #{ self['overtimeIncluded'] }" )
				self["overtimeIncluded"]
			end

			# The weeks_since_injury value is interpreted as a statement of which injury week we 
			# are currently in - the first week commencing at the date of the injury, the second week
			# commencing 7 days after that date etc.
			def matches?(weeks_since_injury)
				weeks_since_injury >= (start_week - 1).to_f && # it's after the prior week, i.e. when injured, you are immediately in the first 
				                                          # week of injury
				(
					end_week.nil? ||
					weeks_since_injury <  end_week.to_f  # it's before the end_week number - i.e. exactly 1 week after an injury,
				  			                               # you are now into the second week of injury
				)				                                          
			end


			def pay_for_this_week( person )
				(
					( 
						person.normal_hours * person.hourly_rate + ( 
							overtime_included ? person.overtime_hours * person.overtime_rate : 0 
						) 
					) * ( percentage_payable / 100 )
				).round(2)
			end


			def report_line(person, report_date)
				{
					name: person.name,
					pay_for_this_week: 	sprintf( "%.2f", pay_for_this_week(					person 			) ),
					weeks_since_injury: sprintf( "%.2f", person.weeks_since_injury( report_date ) ),
					hourly_rate: 				sprintf( "%.6f", person.hourly_rate												),
					overtime_rate: 			sprintf( "%.6f", person.overtime_rate											),
					normal_hours: 			sprintf( "%.2f", person.normal_hours											),
					overtime_hours: 		sprintf( "%.2f", person.overtime_hours										),
					percentage_payable: sprintf( "%.2f", percentage_payable												),
					overtime_included: 	overtime_included.to_s
				}
			end # method report_line

		end # role Rule



end # class Piawe::RuleSet



