class RuleSet


	def initialize(rules_array)
		rules_array || (raise ArgumentError, "rules array is required")
		rules_array.size > 0 || (raise ArgumentError, "rules array must contain at least one entry")
		rules_array.each do |rule_hash|
			add(Rule.played_by rule_hash)
		end
		rules[-1].end_week.nil? || (raise ArgumentError, "last rule must have a terminating + sign")
	end


	def report_line(person, report_date)
		self.each do |rule|
			return rule.report_line( person, report_date ) if rule.matches( person.weeks_since_injury( report_date ) ) 
		end # each rule_hash
	end # method payment_report





	private


		def add(rule)
			# check consistency of rule dates
			(rule.end_week.nil? || rule.end_week > rule.start_week) || (raise ArgumentError, "rule #{rules.size + 1} has an end week of #{rule.end_week} that is not later than it's start week of #{rule.start_week}")
			if rules[-1] # we have existing rules, check we are consistent
				rules[-1].end_week || (raise ArgumentError, "rule #{rules.size} has a terminating + sign, and should have been the last rule, however there was a subsequent rule: #{self.inspect}")
				rule.start_week == rules[-1].end_week + 1 || (raise ArgumentError, "rule #{rules.size} ends at week #{rules[-1].end_week} but rule #{rules.size + 1} starts at week #{rule.start_week} - each rule should start one week after the prior rule ends")
			else # this should be the first rule - check it's start date
				1 == rule.start_week || (raise ArgumentError, "rule 1 should start at week 1, but starts at week #{rule.start_week}")
			end # if we have existing rules
			rules << rule
		end


		def rules 
			@rules ||= []
		end





		include RolePlaying::Context


		# role to be added to a rule hash
		Role :Rule do

			def start_week
				@start_week ||= (
					/(?<starting_week>\d+)[+-]/ =~ applicable_weeks
					starting_week.to_i
				)
			end


			def end_week
				@end_week ||= if /[+$]/ =~ applicable_weeks
												nil
											else
												/\d*[+](?<ending_week>\d+)$/ =~ applicable_weeks
												ending_week
											end # if trailing + sign
			end


			def applicable_weeks
				@applicable_weeks ||= (
					self.has_key["applicableWeeks"] || (raise ArgumentError, "rule hash did not have an applicable_weeks key: self.inspect")
					/(^\d+\-\d+$)|(^\d+\+$)/ =~ self["applicableWeeks"] || (raise ArgumentError, "applicable_weeks key is not in valid format")
					self["applicableWeeks"]
				)
			end


			def matches(weeks_since_injury)
				(start_week..end_week).cover? weeks_since_injury
			end


			def report_line(person, report_date)
				{
					name: person.name,
					weeks_since_injury: person.weeks_since_injury( report_date ),


				}
			end

		end # role Rule



end # class RuleSet



