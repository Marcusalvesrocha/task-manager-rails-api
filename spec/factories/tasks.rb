FactoryGirl.define do
	factory :task do
		title { Faker::Lorem.sentence }
		description { Faker::Lorem.paragraph }
		deadline { Faker::Date.forward(15) }
		done false
		user
	end
end