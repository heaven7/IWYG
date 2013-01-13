require 'faker'
require 'populator'

FactoryGirl.define do

	factory :user do
		sequence(:id, Random.rand(1000)) { |n| n + Random.rand(1000) }
    sequence(:login) { |n| Faker::Name.first_name + n.to_s }
		password "password"
		password_confirmation "password"
		sequence(:email, Random.rand(1000)) {|n| "email_#{n}@test.com" }
		confirmed_at Time.now
  end

  factory :folder do
		title "Inbox"
  end

	factory :comment do
		body Populator.paragraphs(1)

		trait :on_items do
			after_build do |c|
				c.commentable = Factory.build(:item)
			end
		end
	end

  factory :group do
		id (1 + Random.rand(1000))
    title "a Testgroup"
		description Populator.paragraphs(1..3)
		user_id @user
		slug "a-testgroup"
  end

  factory :grouping do
		id (1 + Random.rand(1000))
		association :user, factory: :user
		association :owner, factory: :user
		association :group, factory: :group
  end

	factory :item do
		sequence(:id, Random.rand(1000)) { |n| n + Random.rand(1000) }
    title "a testitem"
		description Populator.paragraphs(1..3)
		association :user, factory: :user
		item_type_id [1..6]
		need [true, false]
  end
	
	factory :item_type do
		trait :good do
			id 1
			title "good"
		end
		trait :transport do
			id 2
			title "transport"
		end
		trait :service do
			id 3
			title "service"
		end
		trait :sharingpoint do
			id 4
			title "sharingpoint"
		end
		trait :wisdom do
			id 5
			title "wisdom"
		end
		trait :knowledge do
			id 6
			title "knowledge"
		end
	end

  factory :message do
		id Random.rand(100)
    to [2,3]
		body "the body of the test message"
		subject "test message"
  end

  factory :notifier do
		user_id Random.rand(100)
		notifyable_id Random.rand(100)
		notifyable_type "User"
  end
	
end
