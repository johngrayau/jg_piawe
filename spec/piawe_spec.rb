require 'spec_helper'

describe Piawe do
  it 'has a version number' do
    expect(Piawe::VERSION).not_to be nil
  end
end



describe Piawe::Person do

	let (:valid) do
		Piawe::Person.played_by (	{
			"name" =>  "Ebony Boycott",
			"hourlyRate" =>  75.0030,
			"overtimeRate" =>  150.0000,
			"normalHours" =>  35.0,
			"overtimeHours" =>  7.3,
			"injuryDate" =>  "2016/05/01" 
		} )
	end

	let (:invalid_format) do
		Piawe::Person.played_by (	{
			"name" =>  nil,
			"hourlyRate" =>  "foo",
			"overtimeRate" =>  "bar",
			"normalHours" =>  "baz",
			"overtimeHours" =>  "twelve",
			"injuryDate" =>  "yesterday" 
		} )
	end

	let (:invalid_values) do
		Piawe::Person.played_by (	{
			"name" =>  nil,
			"hourlyRate" =>  nil,
			"overtimeRate" =>  nil,
			"normalHours" =>  nil,
			"overtimeHours" =>  nil,
			"injuryDate" =>  "2016/01/50" 
		} )
	end

	let (:empty) do
		Piawe::Person.played_by (	Hash.new )
	end


	context "given a valid person_hash" do
		it "has the correct name" 								do expect(valid.name						).to eql("Ebony Boycott"					); end
		it "has the correct hourly rate" 					do expect(valid.hourly_rate			).to eql( 75.003									); end
		it "has the correct overtime rate" 				do expect(valid.overtime_rate		).to eql( 150.0										); end
		it "has the correct normal hours" 				do expect(valid.normal_hours		).to eql(	35.0										); end
		it "has the correct overtime hours" 			do expect(valid.overtime_hours	).to eql( 7.3											); end
		it "has the correct injury date" 					do expect(valid.injury_date			).to eql(	Date.new(2016, 05, 01)	); end
		it "calculates the correct injury weeks" 	do expect( valid.weeks_since_injury( Date.new(2016, 05, 29) ).to_f ).to eql(4.0) ; end
	end # given a valid person_hash


	context "given a person_hash with invalid format" do
		it "rejects the name value" 							do expect {invalid_format.name						}.to raise_error( ArgumentError, /person_hash has a nil value for name key: #{									invalid_format.inspect}/ ); end
		it "rejects the hourly rate value" 				do expect {invalid_format.hourly_rate			}.to raise_error( ArgumentError, /person_hash has a non-numeric value for hourlyRate key: #{    invalid_format.inspect}/ ); end
		it "rejects the overtime rate value" 			do expect {invalid_format.overtime_rate		}.to raise_error( ArgumentError, /person_hash has a non-numeric value for overtimeRate key: #{  invalid_format.inspect}/ ); end
		it "rejects the normal hours value" 			do expect {invalid_format.normal_hours		}.to raise_error( ArgumentError, /person_hash has a non-numeric value for normalHours key: #{   invalid_format.inspect}/ ); end
		it "rejects the overtime hours value" 		do expect {invalid_format.overtime_hours	}.to raise_error( ArgumentError, /person_hash has a non-numeric value for overtimeHours key: #{ invalid_format.inspect}/ ); end
		it "rejects the injury date value" 				do expect {invalid_format.injury_date			}.to raise_error( ArgumentError, /injury date of yesterday is not in yyyy\/mm\/dd format: #{    invalid_format.inspect}/ ); end
	end


	context "given a person_hash with invalid_values" do
		it "rejects the name value" 							do expect {invalid_values.name						}.to raise_error( ArgumentError, /person_hash has a nil value for name key: #{									invalid_values.inspect}/ ); end
		it "rejects the hourly rate value" 				do expect {invalid_values.hourly_rate			}.to raise_error( ArgumentError, /person_hash has a non-numeric value for hourlyRate key: #{    invalid_values.inspect}/ ); end
		it "rejects the overtime rate value" 			do expect {invalid_values.overtime_rate		}.to raise_error( ArgumentError, /person_hash has a non-numeric value for overtimeRate key: #{  invalid_values.inspect}/ ); end
		it "rejects the normal hours value" 			do expect {invalid_values.normal_hours		}.to raise_error( ArgumentError, /person_hash has a non-numeric value for normalHours key: #{   invalid_values.inspect}/ ); end
		it "rejects the overtime hours value" 		do expect {invalid_values.overtime_hours	}.to raise_error( ArgumentError, /person_hash has a non-numeric value for overtimeHours key: #{ invalid_values.inspect}/ ); end
		it "rejects the injury date value" 				do expect {invalid_values.injury_date			}.to raise_error( ArgumentError, /person_hash has an invalidly formatted injuryDate key: #{     invalid_values.inspect}/ ); end
	end


	context "given an empty person_hash" do
		it "rejects the name value" 							do expect {empty.name						}.to raise_error( ArgumentError, /person_hash does not have a key of name: #{						empty.inspect}/ ); end
		it "rejects the hourly rate value" 				do expect {empty.hourly_rate		}.to raise_error( ArgumentError, /person_hash does not have a key of hourlyRate: #{			empty.inspect}/ ); end
		it "rejects the overtime rate value" 			do expect {empty.overtime_rate	}.to raise_error( ArgumentError, /person_hash does not have a key of overtimeRate: #{		empty.inspect}/ ); end
		it "rejects the normal hours value" 			do expect {empty.normal_hours		}.to raise_error( ArgumentError, /person_hash does not have a key of normalHours: #{		empty.inspect}/ ); end
		it "rejects the overtime hours value" 		do expect {empty.overtime_hours	}.to raise_error( ArgumentError, /person_hash does not have a key of overtimeHours: #{	empty.inspect}/ ); end
		it "rejects the injury date value" 				do expect {empty.injury_date		}.to raise_error( ArgumentError, /person_hash does not have a key of injuryDate: #{			empty.inspect}/ ); end
	end

end # describe Piawe::Person

