require "spec_helper"

class User < SuperModel::Base
  
end

class Action < SuperModel::Base
  
end

describe Protocolist do
  before :each do
    Action.destroy_all
    @actor = User.new
    Protocolist.actor = @actor
    Protocolist.action_class = ::Action
  end
  
  it 'should silently skip saving if actor is falsy' do
    Protocolist.actor = nil
    expect {Protocolist.fire :alarm}.not_to change{Action.count}
    expect {Protocolist.fire :alarm}.not_to raise_error
  end
  
  it 'should save a simple record' do
    expect {Protocolist.fire :alarm}.to change{Action.count}.by 1
    
    Action.last.actor.should == @actor
    Action.last.type.should == :alarm
  end
end
