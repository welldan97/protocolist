require "spec_helper"

class User < SuperModel::Base

end

class Activity < SuperModel::Base
  attributes :data, :language_key, :secondary_target_type, :secondary_target_id
end

class Firestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  def delete
    fire :delete, :target => false
  end

  def myself
    fire :myself
  end

  def love_letter_for_mary
    user = User.create(:name => 'Mary')
    fire :love_letter, :target => user, :data => '<3 <3 <3'
  end
end

class SimpleFirestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  fires :create
end

class ConditionalFirestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  fires :i_will_be_saved, :on => :create, :if => :return_true_please
  fires :and_i_won_t, :on => :create, :if => :return_false_please
  fires :but_i_will_too, :on => :create, :unless => :return_false_please

  def return_false_please
    false
  end

  def return_true_please
    true
  end
end

class ComplexFirestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  fires :yohoho, :on =>[:create, :destroy], :target => false, :data => :hi
  fires :updates_tags, :on =>:update, :tags => 'some,csv,tags,here', data: :changes

  def hi
    'Hi!'
  end

end

class CustomFirestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  fires :updates_tags, on: :update, tags: 'some,csv,tags,here', data: :changes
  fires :destroyed_by,
        on: :destroy,
        secondary_target: User.create(:name => 'Mary'),
        data: :changes

end

describe Protocolist::ModelAdditions do
  before :each do
    Activity.destroy_all
    @actor = User.new(:name => 'Bill')
    Protocolist.actor = @actor
    Protocolist.activity_class = Activity
  end

  describe 'direct fire method call' do
    before :each do
      @firestarter = Firestarter.new
    end

    it 'saves record with target and data' do
      expect {
        @firestarter.love_letter_for_mary
      }.to change{Activity.count}.by 1
      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :love_letter
      Activity.last.target.name.should == 'Mary'
      Activity.last.data.should == '<3 <3 <3'
    end

    it 'saves record with self as target if target is not set' do
      expect {
        @firestarter.myself
      }.to change{Activity.count}.by 1
      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :myself
      Activity.last.target.should == @firestarter
    end

    it 'saves record without target if target set to false' do
      expect {
        @firestarter.delete
      }.to change{Activity.count}.by 1
      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :delete
      Activity.last.target.should be_false
    end
  end

  describe 'fires callback' do
    it 'saves record when called with minimal options' do
      expect {
        SimpleFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 1
      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :create
      Activity.last.target.name.should == 'Ted'
    end

    it 'saves record when called with complex options' do

      #first create record

      expect {
          ComplexFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 1
      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :yohoho
      Activity.last.target.should_not be
      Activity.last.data.should == 'Hi!'

      #then destroy record

      expect {
        ComplexFirestarter.last.destroy
      }.to change{Activity.count}.by 1
      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :yohoho
      Activity.last.target.should_not be
      Activity.last.data.should == 'Hi!'
    end

    it 'saves checks :if condition' do
      expect {
        ConditionalFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 2
      Activity.first.activity_type.should == :i_will_be_saved
    end

    it 'saves checks :unless condition' do
      expect {
        ConditionalFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 2
      Activity.first.activity_type.should == :i_will_be_saved
      Activity.find_by_activity_type(:and_i_won_t).should be_nil
      Activity.find_by_activity_type(:but_i_will_too).should_not be_nil
    end

    it 'allows additional attributes to be defined' do

      #first create record

      expect {
        CustomFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 0

      #then update record

      expect {
        CustomFirestarter.last.update_attribute(:name, 'Rob')
      }.to change{Activity.count}.by 1
      Activity.last.activity_type.should == :updates_tags
      Activity.last.tags.should ==  'some,csv,tags,here'
      Activity.last.data.should ==  {"name"=>["Ted", "Rob"]}
    end

    it 'allows additionally defined attributes to be references' do

      #first create record

      expect {
        CustomFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 0

      #then update record

      expect {
        CustomFirestarter.last.destroy
      }.to change{Activity.count}.by 1
      Activity.last.activity_type.should == :destroyed_by
      Activity.last.secondary_target.should ==  User.first
    end

  end


end
