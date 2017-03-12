require 'spec_helper'

describe Piawe do
  it 'has a version number' do
    expect(Piawe::VERSION).not_to be nil
  end
end



describe Piawe::Person, :private do

	subject do
		Piawe::Person.played_by (	{
			"name" =>  "Ebony Boycott",
			"hourlyRate" =>  75.0030,
			"overtimeRate" =>  150.0000,
			"normalHours" =>  35.0,
			"overtimeHours" =>  7.3,
			"injuryDate" =>  "2016/05/01" 
		} )
	end

	it { is_expected.to respond_to(:name) }
	it { is_expected.to respond_to(:hourly_rate) }
	it { is_expected.to respond_to(:overtime_rate) }

end

