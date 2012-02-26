require "spec_helper"

class User < SuperModel::Base

end

class Activity < SuperModel::Base

end

class Firestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  def delete
    fire :delete, :object => false
  end

  def myself
    fire :myself
  end

  def love_letter_for_mary
    user = User.create(:name => 'Mary')
    fire :love_letter, :object => user, :data => '<3 <3 <3'
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

  def return_false_please
    false
  end

  def return_true_please
    true
  end
end

class ComplexFirestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  fires :yohoho, :on =>[:create, :destroy], :object => false, :data => :hi

  def hi
    'Hi!'
  end
end

describe Protocolist::ModelAdditions do
  before :each do
    Activity.destroy_all
    @subject = User.new(:name => 'Bill')
    Protocolist.subject = @subject
    Protocolist.activity_class = Activity
  end

  describe 'direct fire method call' do
    before :each do
      @firestarter = Firestarter.new
    end

    it 'saves record with object and data' do
      expect {
        @firestarter.love_letter_for_mary
      }.to change{Activity.count}.by 1
      Activity.last.subject.name.should == 'Bill'
      Activity.last.type.should == :love_letter
      Activity.last.object.name.should == 'Mary'
      Activity.last.data.should == '<3 <3 <3'
    end

    it 'saves record with self as object if object is not set' do
      expect {
        @firestarter.myself
      }.to change{Activity.count}.by 1
      Activity.last.subject.name.should == 'Bill'
      Activity.last.type.should == :myself
      Activity.last.object.should == @firestarter
    end

    it 'saves record without object if object set to false' do
      expect {
        @firestarter.delete
      }.to change{Activity.count}.by 1
      Activity.last.subject.name.should == 'Bill'
      Activity.last.type.should == :delete
      Activity.last.object.should be_false
    end
  end

  describe 'fires callback' do
    it 'saves record when called with minimal options' do
      expect {
        SimpleFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 1
      Activity.last.subject.name.should == 'Bill'
      Activity.last.type.should == :create
      Activity.last.object.name.should == 'Ted'
    end

    it 'saves record when called with complex options' do

      #first create record

      expect {
          ComplexFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 1
      Activity.last.subject.name.should == 'Bill'
      Activity.last.type.should == :yohoho
      Activity.last.object.should_not be
      Activity.last.data.should == 'Hi!'

      #then destroy record

      expect {
        ComplexFirestarter.last.destroy
      }.to change{Activity.count}.by 1
      Activity.last.subject.name.should == 'Bill'
      Activity.last.type.should == :yohoho
      Activity.last.object.should_not be
      Activity.last.data.should == 'Hi!'
    end

    it 'saves checks conditions' do
      expect {
        ConditionalFirestarter.create(:name => 'Ted')
      }.to change{Activity.count}.by 1
      Activity.last.type.should == :i_will_be_saved
    end
  end


end
