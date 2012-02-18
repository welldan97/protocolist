require "spec_helper"

class User < SuperModel::Base
  
end

class Activity < SuperModel::Base
  
end

class FirestartersController
  #stub before filter
  def self.before_filter *args
  end
  
  include Protocolist::ControllerAdditions
  def explicit_use
    fire :gogogo, :object => User.new(:name => 'Lisa'), :data => '<3 <3 <3'
  end
  
  def implicit_use
    @firestarter = User.new(:name => 'Marge')
    fire
  end
end

describe Protocolist::ControllerAdditions do
  before :each do
    Activity.destroy_all
    user = User.new(:name => 'Bill')
    @controller = FirestartersController.new
    
    @controller.stub(:current_user){user}
    @controller.stub(:controller_name){'firestarters'}
    @controller.stub(:action_name){'quick_and_dirty_action_stub'}
    
    @controller.initilize_protocolist
  end
  
  describe 'direct fire method call' do
    it 'saves record with object and data when called explicitly' do
      @controller.explicit_use
      
      Activity.last.subject.name.should == 'Bill'
      Activity.last.type.should == :gogogo
      Activity.last.object.name.should == 'Lisa'
      Activity.last.data.should == '<3 <3 <3'
    end
    
    it 'saves record with object and data when called implicitly' do
      @controller.implicit_use
      
      Activity.last.subject.name.should == 'Bill'
      Activity.last.type.should == :quick_and_dirty_action_stub
      Activity.last.object.name.should == 'Marge'
    end
  end
end
