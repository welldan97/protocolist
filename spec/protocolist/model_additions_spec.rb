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

describe Protocolist::ModelAdditions do
  before :each do
    Activity.destroy_all
    @subject = User.new(:name => 'Bill')
    Protocolist.subject = @subject
    Protocolist.activity_class = Activity
    @firestarter = Firestarter.new
  end
  
  describe 'direct fire method call' do
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
  
  describe 'fire callbacks' do
    
  end
end
  
