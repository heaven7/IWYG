require 'spec_helper'

describe Message do

	before :all do
		@sender = create(:user)
		@message = build(:message, author: @sender)
	end 

	subject { @message }

	it { should belong_to(:author) }
	it { should have_many(:message_copies) }
	it { should have_many(:recipients).through(:message_copies) }
	it { should have_one(:custom) }
	
	describe "validations" do
		
		it "should be valid" do
			@message.should be_valid
		end

		it "has a valid factory" do
			@message.should be_valid
		end
	
		it "has an author" do
			@message.author.should be @sender	
		end

		it "has a subject" do
			@message.subject.should == "test message"	
		end

		it "has a body" do
			@message.body.should == "the body of the test message"	
		end

		it 'is invalid without a subject' do
			message = Message.new
			message.should_not be_valid
		end

	end

	describe "sending messages" do

		before :each do
			@receiver = create(:user)
			@message = create(:message, author: @sender, to: @receiver.login)
		end

		it "sender has sent a message" do
			@sender.sent_messages.count.should be 1
		end 
			
		it "receiver gets the message" do
			@receiver.received_messages.count.should be 1
		end

		it "receiver can reply to user" do
			@original = @receiver.received_messages.first
			@message = @receiver.sent_messages.build(
				:to => @original.author.login, 
				:subject => @original.subject, :body => "this is a reply"
			)
			expect{@message.save}.to change{@sender.received_messages.count}.by(1)
		end
	end

	

end
