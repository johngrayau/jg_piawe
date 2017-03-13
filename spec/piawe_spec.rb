require 'spec_helper'


describe Piawe::Person do

  let (:valid) do
    Piawe::Person.played_by ( {
      "name" =>  "Ebony Boycott",
      "hourlyRate" =>  75.0030,
      "overtimeRate" =>  150.0000,
      "normalHours" =>  35.0,
      "overtimeHours" =>  7.3,
      "injuryDate" =>  "2016/05/01" 
    } )
  end

  let (:invalid_format) do
    Piawe::Person.played_by ( {
      "name" =>  nil,
      "hourlyRate" =>  "foo",
      "overtimeRate" =>  "bar",
      "normalHours" =>  "baz",
      "overtimeHours" =>  "twelve",
      "injuryDate" =>  "yesterday" 
    } )
  end

  let (:invalid_values) do
    Piawe::Person.played_by ( {
      "name" =>  nil,
      "hourlyRate" =>  nil,
      "overtimeRate" =>  nil,
      "normalHours" =>  nil,
      "overtimeHours" =>  nil,
      "injuryDate" =>  "2016/01/50" 
    } )
  end

  let (:empty) do
    Piawe::Person.played_by ( Hash.new )
  end


  context "given a valid person_hash" do
    it "has the correct name"                 do expect(valid.name            ).to eql("Ebony Boycott"          ); end
    it "has the correct hourly rate"          do expect(valid.hourly_rate     ).to eql( 75.003                  ); end
    it "has the correct overtime rate"        do expect(valid.overtime_rate   ).to eql( 150.0                   ); end
    it "has the correct normal hours"         do expect(valid.normal_hours    ).to eql( 35.0                    ); end
    it "has the correct overtime hours"       do expect(valid.overtime_hours  ).to eql( 7.3                     ); end
    it "has the correct injury date"          do expect(valid.injury_date     ).to eql( Date.new(2016, 05, 01)  ); end
    it "calculates the correct injury weeks"  do expect( valid.weeks_since_injury( Date.new(2016, 05, 29) ).to_f ).to eql(4.0) ; end
  end # given a valid person_hash


  context "given a person_hash with invalid format" do
    it "rejects the name value"               do expect {invalid_format.name            }.to raise_error( ArgumentError, /person_hash has a nil value for name key: #{                  invalid_format.inspect}/ ); end
    it "rejects the hourly rate value"        do expect {invalid_format.hourly_rate     }.to raise_error( ArgumentError, /person_hash has a non-numeric value for hourlyRate key: #{    invalid_format.inspect}/ ); end
    it "rejects the overtime rate value"      do expect {invalid_format.overtime_rate   }.to raise_error( ArgumentError, /person_hash has a non-numeric value for overtimeRate key: #{  invalid_format.inspect}/ ); end
    it "rejects the normal hours value"       do expect {invalid_format.normal_hours    }.to raise_error( ArgumentError, /person_hash has a non-numeric value for normalHours key: #{   invalid_format.inspect}/ ); end
    it "rejects the overtime hours value"     do expect {invalid_format.overtime_hours  }.to raise_error( ArgumentError, /person_hash has a non-numeric value for overtimeHours key: #{ invalid_format.inspect}/ ); end
    it "rejects the injury date value"        do expect {invalid_format.injury_date     }.to raise_error( ArgumentError, /injury date of yesterday is not in yyyy\/mm\/dd format: #{    invalid_format.inspect}/ ); end
  end


  context "given a person_hash with invalid_values" do
    it "rejects the name value"               do expect {invalid_values.name            }.to raise_error( ArgumentError, /person_hash has a nil value for name key: #{                  invalid_values.inspect}/ ); end
    it "rejects the hourly rate value"        do expect {invalid_values.hourly_rate     }.to raise_error( ArgumentError, /person_hash has a non-numeric value for hourlyRate key: #{    invalid_values.inspect}/ ); end
    it "rejects the overtime rate value"      do expect {invalid_values.overtime_rate   }.to raise_error( ArgumentError, /person_hash has a non-numeric value for overtimeRate key: #{  invalid_values.inspect}/ ); end
    it "rejects the normal hours value"       do expect {invalid_values.normal_hours    }.to raise_error( ArgumentError, /person_hash has a non-numeric value for normalHours key: #{   invalid_values.inspect}/ ); end
    it "rejects the overtime hours value"     do expect {invalid_values.overtime_hours  }.to raise_error( ArgumentError, /person_hash has a non-numeric value for overtimeHours key: #{ invalid_values.inspect}/ ); end
    it "rejects the injury date value"        do expect {invalid_values.injury_date     }.to raise_error( ArgumentError, /person_hash has an invalidly formatted injuryDate key: #{     invalid_values.inspect}/ ); end
  end


  context "given an empty person_hash" do
    it "rejects the name value"               do expect {empty.name           }.to raise_error( ArgumentError, /person_hash does not have a key of name: #{           empty.inspect}/ ); end
    it "rejects the hourly rate value"        do expect {empty.hourly_rate    }.to raise_error( ArgumentError, /person_hash does not have a key of hourlyRate: #{     empty.inspect}/ ); end
    it "rejects the overtime rate value"      do expect {empty.overtime_rate  }.to raise_error( ArgumentError, /person_hash does not have a key of overtimeRate: #{   empty.inspect}/ ); end
    it "rejects the normal hours value"       do expect {empty.normal_hours   }.to raise_error( ArgumentError, /person_hash does not have a key of normalHours: #{    empty.inspect}/ ); end
    it "rejects the overtime hours value"     do expect {empty.overtime_hours }.to raise_error( ArgumentError, /person_hash does not have a key of overtimeHours: #{  empty.inspect}/ ); end
    it "rejects the injury date value"        do expect {empty.injury_date    }.to raise_error( ArgumentError, /person_hash does not have a key of injuryDate: #{     empty.inspect}/ ); end
  end

end # describe Piawe::Person




describe Piawe do

  let (:report_date) do 
    Date.new(2017, 3, 1)
  end

  let (:people_array) do
    [
      {"name" => "Ebony Boycott",         "hourlyRate" => 75.0030, "overtimeRate" => 150.0000,  "normalHours" => 35.0, "overtimeHours" => 7.3,  "injuryDate" => "2016/05/01" }, # 43.42857142857143
      {"name" => "Geoff Rainford-Brent",  "hourlyRate" => 30.1234, "overtimeRate" => 60.3456,   "normalHours" => 25.0, "overtimeHours" => 10.7, "injuryDate" => "2016/08/04" }, # 29.857142857142858
      {"name" => "Meg Gillespie",         "hourlyRate" => 50.0000, "overtimeRate" => 100.0000,  "normalHours" => 37.5, "overtimeHours" => 0.0,  "injuryDate" => "2015/12/31" }, # 60.857142857142854
      {"name" => "Jason Lanning",         "hourlyRate" => 40.0055, "overtimeRate" => 90.9876,   "normalHours" => 40.0, "overtimeHours" => 12.4, "injuryDate" => "2013/01/01" }  # 217.14285714285714
    ]
  end


  let (:rules_array) do
    [
      {"applicableWeeks" => "1-26",   "percentagePayable" => 90, "overtimeIncluded" => true},
      {"applicableWeeks" => "27-52",  "percentagePayable" => 80, "overtimeIncluded" => true},
      {"applicableWeeks" => "53-79",  "percentagePayable" => 70, "overtimeIncluded" => true},
      {"applicableWeeks" => "80-104", "percentagePayable" => 60, "overtimeIncluded" => false},
      {"applicableWeeks" => "105+",   "percentagePayable" => 10, "overtimeIncluded" => false}
    ]
  end


  let (:piawe) do
    Piawe.new(people_array, rules_array)
  end


  let (:report) do
    piawe.report(report_date)
  end

  it 'has a version number' do
    expect(Piawe::VERSION).not_to be nil
  end


  context "given valid arguments, the report" do
    it "should have the correct date"               do expect( report[:report_date]       ).to eql( report_date.strftime("%Y/%m/%d")); end
    it "should have the correct number of lines"    do expect( report[:report_lines].size ).to eql( 4                               ); end
    #
    it "should have the correct name for person 1"                do expect( report[:report_lines][0][:name               ] ).to eql(people_array[0]["name"]); end
    it "should have the correct pay for person 1"                 do expect( report[:report_lines][0][:pay_for_this_week  ] ).to eql( "2976.08"   ); end
    it "should have the correct weeks_since_injury for person 1"  do expect( report[:report_lines][0][:weeks_since_injury ] ).to eql( "43.43"     ); end
    it "should have the correct hourly rate for person 1"         do expect( report[:report_lines][0][:hourly_rate        ] ).to eql( "75.003000" ); end
    it "should have the correct overtime rate for person 1"       do expect( report[:report_lines][0][:overtime_rate      ] ).to eql( "150.000000"); end
    it "should have the correct normal hours for person 1"        do expect( report[:report_lines][0][:normal_hours       ] ).to eql( "35.00"     ); end
    it "should have the correct overtime hours for person 1"      do expect( report[:report_lines][0][:overtime_hours     ] ).to eql( "7.30"      ); end
    it "should have the correct percentage_payable for person 1"  do expect( report[:report_lines][0][:percentage_payable ] ).to eql( "80.00"     ); end
    it "should have the correct overtime_included for person 1"   do expect( report[:report_lines][0][:overtime_included  ] ).to eql( "true"      ); end
    #
    it "should have the correct name for person 2"                do expect( report[:report_lines][1][:name               ] ).to eql(people_array[1]["name"]); end
    it "should have the correct pay for person 2"                 do expect( report[:report_lines][1][:pay_for_this_week  ] ).to eql( "1119.03"   ); end
    it "should have the correct weeks_since_injury for person 2"  do expect( report[:report_lines][1][:weeks_since_injury ] ).to eql( "29.86"     ); end
    it "should have the correct hourly rate for person 2"         do expect( report[:report_lines][1][:hourly_rate        ] ).to eql( "30.123400" ); end
    it "should have the correct overtime rate for person 2"       do expect( report[:report_lines][1][:overtime_rate      ] ).to eql( "60.345600" ); end
    it "should have the correct normal hours for person 2"        do expect( report[:report_lines][1][:normal_hours       ] ).to eql( "25.00"     ); end
    it "should have the correct overtime hours for person 2"      do expect( report[:report_lines][1][:overtime_hours     ] ).to eql( "10.70"     ); end
    it "should have the correct percentage_payable for person 2"  do expect( report[:report_lines][1][:percentage_payable ] ).to eql( "80.00"     ); end
    it "should have the correct overtime_included for person 2"   do expect( report[:report_lines][1][:overtime_included  ] ).to eql( "true"      ); end
    #
    it "should have the correct name for person 3"                do expect( report[:report_lines][2][:name               ] ).to eql(people_array[2]["name"]); end
    it "should have the correct pay for person 3"                 do expect( report[:report_lines][2][:pay_for_this_week  ] ).to eql( "1312.50"   ); end
    it "should have the correct weeks_since_injury for person 3"  do expect( report[:report_lines][2][:weeks_since_injury ] ).to eql( "60.86"     ); end
    it "should have the correct hourly rate for person 3"         do expect( report[:report_lines][2][:hourly_rate        ] ).to eql( "50.000000" ); end
    it "should have the correct overtime rate for person 3"       do expect( report[:report_lines][2][:overtime_rate      ] ).to eql( "100.000000"); end
    it "should have the correct normal hours for person 3"        do expect( report[:report_lines][2][:normal_hours       ] ).to eql( "37.50"     ); end
    it "should have the correct overtime hours for person 3"      do expect( report[:report_lines][2][:overtime_hours     ] ).to eql( "0.00"      ); end
    it "should have the correct percentage_payable for person 3"  do expect( report[:report_lines][2][:percentage_payable ] ).to eql( "70.00"     ); end
    it "should have the correct overtime_included for person 3"   do expect( report[:report_lines][2][:overtime_included  ] ).to eql( "true"      ); end
    #
    it "should have the correct name for person 4"                do expect( report[:report_lines][3][:name               ] ).to eql(people_array[3]["name"]); end
    it "should have the correct pay for person 4"                 do expect( report[:report_lines][3][:pay_for_this_week  ] ).to eql( "160.02"    ); end
    it "should have the correct weeks_since_injury for person 4"  do expect( report[:report_lines][3][:weeks_since_injury ] ).to eql( "217.14"    ); end
    it "should have the correct hourly rate for person 4"         do expect( report[:report_lines][3][:hourly_rate        ] ).to eql( "40.005500" ); end
    it "should have the correct overtime rate for person 4"       do expect( report[:report_lines][3][:overtime_rate      ] ).to eql( "90.987600" ); end
    it "should have the correct normal hours for person 4"        do expect( report[:report_lines][3][:normal_hours       ] ).to eql( "40.00"     ); end
    it "should have the correct overtime hours for person 4"      do expect( report[:report_lines][3][:overtime_hours     ] ).to eql( "12.40"     ); end
    it "should have the correct percentage_payable for person 4"  do expect( report[:report_lines][3][:percentage_payable ] ).to eql( "10.00"     ); end
    it "should have the correct overtime_included for person 4"   do expect( report[:report_lines][3][:overtime_included  ] ).to eql( "false"     ); end
  end
end # describe Piawe



