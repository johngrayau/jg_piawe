require 'spec_helper'

describe RuleSet::Rule do

	let (:valid) do 
		RuleSet::Rule.played_by ( {
			"applicableWeeks" 	=> "1-26",
			"percentagePayable" => 90,
			"overtimeIncluded" 	=> true
		} )
	end

	let (:invalid) do 
		RuleSet::Rule.played_by ( {
			"applicableWeeks" 	=> "foo",
			"percentagePayable" => "bar",
			"overtimeIncluded" 	=> "baz"
		} )
	end

	let (:empty) do 
		RuleSet::Rule.played_by ( Hash.new )
	end
	
	let (:report_date) do 
		Date.new(2017, 3, 1)
	end

	let (:person) do
		Piawe::Person.played_by (	{
			"name" =>  "test person",
			"hourlyRate" =>  75.0,
			"overtimeRate" =>  150.0,
			"normalHours" =>  35.0,
			"overtimeHours" =>  5,
			"injuryDate" =>  (report_date - 10.weeks).strftime("%Y/%m/%d")
		} )
	end

	let (:overtime_included) do 
		RuleSet::Rule.played_by ( {
			"applicableWeeks" 	=> "1-26",
			"percentagePayable" => 90,
			"overtimeIncluded" 	=> true
		} )
	end


	let (:overtime_not_included) do 
		RuleSet::Rule.played_by ( {
			"applicableWeeks" 	=> "1-26",
			"percentagePayable" => 60,
			"overtimeIncluded" 	=> false
		} )
	end


	context "given a valid rule_hash" do
		it "has the correct start week" 				do expect( valid.start_week 				).to eql(	1 		); end
		it "has the correct end week"   				do expect( valid.end_week   				).to eql(	26		); end
		it "has the correct percentage payable" do expect( valid.percentage_payable	).to eql(	90		); end
		it "has the correct overtime included" 	do expect( valid.overtime_included 	).to eql(	true  ); end
	end


	context "given an invalid rule_hash" do
		it "rejects the invalid start week value" 				do expect{ invalid.start_week 			  }.to raise_error( ArgumentError, /applicableWeeks key is not in valid format/																													); end
		it "rejects the invalid end week value"   				do expect{ invalid.end_week   				}.to raise_error( ArgumentError, /applicableWeeks key is not in valid format/																								 					); end
		it "rejects the invalid percentage payable value" do expect{ invalid.percentage_payable	}.to raise_error( ArgumentError, /rule_hash has a non-numeric value for percentagePayable key: #{invalid['percentagePayable']}/				); end
		it "rejects the invalid overtime included value" 	do expect{ invalid.overtime_included 	}.to raise_error( ArgumentError, /overtimeIncluded value was not a boolean true or false - value was #{ invalid['overtimeIncluded'] }/); end
	end


	context "given an empty rule_hash" do
		it "rejects the missing start week value" 				do expect{ empty.start_week 			  }.to raise_error( ArgumentError, /rule hash did not have an applicableWeeks key: #{  empty.inspect}/ ); end
		it "rejects the missing end week value"   				do expect{ empty.end_week   				}.to raise_error( ArgumentError, /rule hash did not have an applicableWeeks key: #{  empty.inspect}/ ); end
		it "rejects the missing percentage payable value" do expect{ empty.percentage_payable	}.to raise_error( ArgumentError, /rule_hash does not have a percentagePayable key: #{empty.inspect}/ ); end
		it "rejects the missing overtime included value" 	do expect{ empty.overtime_included 	}.to raise_error( ArgumentError, /rule_hash does not have an overtimeIncluded key: #{empty.inspect}/ ); end
	end

	context "given a matching weeks-since-injury" do
		it "should match" do expect( valid.matches?( 10 ) ).to eql(true); end
	end

	context "given a non-matching weeks-since-injury" do
		it "should not match" do expect( valid.matches?( 0  ) ).to eql(false); end
		it "should not match" do expect( valid.matches?( 27 ) ).to eql(false); end
	end


	context "given a rule hash with overtime included" do
		it "calculates the correct pay with overtime" do expect( overtime_included.pay_for_this_week( person 							) 			).to eql( 3037.5 ); end
		it "creates the correct report line" 					do expect( overtime_included.report_line(				person, report_date	).to_s 	).to eql( '{:name=>"test person", :pay_for_this_week=>"3037.50", :weeks_since_injury=>"10.00", :hourly_rate=>"75.000000", :overtime_rate=>"150.000000", :normal_hours=>"35.00", :overtime_hours=>"5.00", :percentage_payable=>"90.00", :overtime_included=>true}' ); end
	end


	context "given a rule hash with overtime not included" do
		it "calculates the correct pay without overtime" do expect( overtime_not_included.pay_for_this_week( person ) ).to eql( 1575.0 ); end
		it "creates the correct report line" 						 do expect( overtime_not_included.report_line(person, report_date	).to_s 	).to eql( '{:name=>"test person", :pay_for_this_week=>"1575.00", :weeks_since_injury=>"10.00", :hourly_rate=>"75.000000", :overtime_rate=>"150.000000", :normal_hours=>"35.00", :overtime_hours=>"5.00", :percentage_payable=>"60.00", :overtime_included=>false}' ); end
	end


end # describe RuleSet::Rule




describe RuleSet, :private do

	let (:overlapping_rules_array) do
		[
	    {"applicableWeeks" => "1-26",   "percentagePayable" => 90, "overtimeIncluded" => true},
	    {"applicableWeeks" => "26-52",  "percentagePayable" => 80, "overtimeIncluded" => true},
	    {"applicableWeeks" => "53-79",  "percentagePayable" => 70, "overtimeIncluded" => true},
	    {"applicableWeeks" => "80-104", "percentagePayable" => 60, "overtimeIncluded" => false},
	    {"applicableWeeks" => "104+",   "percentagePayable" => 10, "overtimeIncluded" => false}
		]
	end


	let (:gapped_rules_array) do
		[
	    {"applicableWeeks" => "1-26",   "percentagePayable" => 90, "overtimeIncluded" => true},
	    {"applicableWeeks" => "28-52",  "percentagePayable" => 80, "overtimeIncluded" => true},
	    {"applicableWeeks" => "53-79",  "percentagePayable" => 70, "overtimeIncluded" => true},
	    {"applicableWeeks" => "80-104", "percentagePayable" => 60, "overtimeIncluded" => false},
	    {"applicableWeeks" => "105+",   "percentagePayable" => 10, "overtimeIncluded" => false}
		]
	end


	let (:early_terminated_rules_array) do
		[
	    {"applicableWeeks" => "1-26",   "percentagePayable" => 90, "overtimeIncluded" => true},
	    {"applicableWeeks" => "27-52",  "percentagePayable" => 80, "overtimeIncluded" => true},
	    {"applicableWeeks" => "53+",  "percentagePayable" => 70, "overtimeIncluded" => true},
	    {"applicableWeeks" => "80-104", "percentagePayable" => 60, "overtimeIncluded" => false},
	    {"applicableWeeks" => "105+",   "percentagePayable" => 10, "overtimeIncluded" => false}
		]
	end


	let (:unterminated_rules_array) do
		[
	    {"applicableWeeks" => "1-26",   "percentagePayable" => 90, "overtimeIncluded" => true},
	    {"applicableWeeks" => "27-52",  "percentagePayable" => 80, "overtimeIncluded" => true},
	    {"applicableWeeks" => "53-79",  "percentagePayable" => 70, "overtimeIncluded" => true},
	    {"applicableWeeks" => "80-104", "percentagePayable" => 60, "overtimeIncluded" => false}
		]
	end


	let (:late_starting_rules_array) do
		[
	    {"applicableWeeks" => "10-26",  "percentagePayable" => 90, "overtimeIncluded" => true},
	    {"applicableWeeks" => "27-52",  "percentagePayable" => 80, "overtimeIncluded" => true},
	    {"applicableWeeks" => "53-79",  "percentagePayable" => 70, "overtimeIncluded" => true},
	    {"applicableWeeks" => "80-104", "percentagePayable" => 60, "overtimeIncluded" => false},
	    {"applicableWeeks" => "105+",   "percentagePayable" => 10, "overtimeIncluded" => false}
		]
	end


	let (:valid_rules_array) do
		[
	    {"applicableWeeks" => "1-26",   "percentagePayable" => 90, "overtimeIncluded" => true},
	    {"applicableWeeks" => "27-52",  "percentagePayable" => 80, "overtimeIncluded" => true},
	    {"applicableWeeks" => "53-79",  "percentagePayable" => 70, "overtimeIncluded" => true},
	    {"applicableWeeks" => "80-104", "percentagePayable" => 60, "overtimeIncluded" => false},
	    {"applicableWeeks" => "105+",   "percentagePayable" => 10, "overtimeIncluded" => false}
		]
	end


	let (:valid) do RuleSet.new( valid_rules_array ); end

	let (:report_date) do 
		Date.new(2017, 3, 1)
	end

	let (:person) do
		Piawe::Person.played_by (	{
			"name" =>  "test person",
			"hourlyRate" =>  75.0,
			"overtimeRate" =>  150.0,
			"normalHours" =>  35.0,
			"overtimeHours" =>  5,
			"injuryDate" =>  (report_date - 100.weeks).strftime("%Y/%m/%d")
		} )
	end

	context "given an invalid argument" do
		it "should raise an exception" do expect { RuleSet.new("foo") }.to raise_error( ArgumentError, /rules array is required - got "foo"/ ); end
	end

	context "given an empty argument" do
		it "should raise an exception" do expect { RuleSet.new( Array.new ) }.to raise_error( ArgumentError, /rules array must contain at least one entry/ ); end
	end

  context "given an overlapping rules array" do
  	it "should raise an exception" do expect { RuleSet.new(overlapping_rules_array) }.to raise_error( ArgumentError, /rule 1 ends at week 26 but rule 2 starts at week 26 - each rule should start one week after the prior rule ends/ ); end
  end

  context "given a gapped rules array" do
  	it "should raise an exception" do expect { RuleSet.new(gapped_rules_array) }.to raise_error( ArgumentError, /rule 1 ends at week 26 but rule 2 starts at week 28 - each rule should start one week after the prior rule ends/ ); end
  end

  context "given an early-terminating rules array" do
  	it "should raise an exception" do expect { RuleSet.new(early_terminated_rules_array) }.to raise_error( ArgumentError, /rule 3 has a terminating \+ sign, and should have been the last rule, however there was a subsequent rule: #{early_terminated_rules_array[3].inspect}/ ); end
  end

  context "given an un-terminated rules array" do
  	it "should raise an exception" do expect { RuleSet.new(unterminated_rules_array) }.to raise_error( ArgumentError, /last rule must have a terminating \+ sign/ ); end
  end

  context "given a late starting rules array" do
  	it "should raise an exception" do expect { RuleSet.new(late_starting_rules_array) }.to raise_error( ArgumentError, /rule 1 should start at week 1, but starts at week 10/ ); end
  end

  context "given a valid rules array" do
  	it "should have the correct size" 			 					do expect( valid.rules.size ).to eql(5); end
  	it "should have the correct start weeks" 					do expect( valid.rules.map(	&:start_week					)	).to match_array( [ 1, 27, 53, 80, 105							] ); end
  	it "should have the correct end weeks"   					do expect( valid.rules.map(	&:end_week						) ).to match_array( [ 26, 52, 79, 104, nil						] ); end
  	it "should have the correct percentage payables" 	do expect( valid.rules.map(	&:percentage_payable	) ).to match_array( [ 90, 80, 70, 60, 10							] ); end
  	it "should have the correct overtime includeds" 	do expect( valid.rules.map(	&:overtime_included		) ).to match_array( [ true, true, true, false, false	] ); end
  	it "should return the right report line"					do expect( valid.report_line(person, report_date	).to_s 	).to eql( '{:name=>"test person", :pay_for_this_week=>"1575.00", :weeks_since_injury=>"100.00", :hourly_rate=>"75.000000", :overtime_rate=>"150.000000", :normal_hours=>"35.00", :overtime_hours=>"5.00", :percentage_payable=>"60.00", :overtime_included=>false}' ); end
  end



end # describe RuleSet


