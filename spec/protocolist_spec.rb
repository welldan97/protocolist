require "spec_helper"

class User < SuperModel::Base

end

class Activity < SuperModel::Base

end

describe Protocolist do
  let(:actor) { User.new(name: 'Bill') }
  let(:another_actor) { User.new(name: 'Bob') }
  let(:target) { User.new(name: 'Mary') }
  
  before do
    Activity.destroy_all
    
    Protocolist.actor = actor
    Protocolist.activity_class = Activity
  end

  it 'should silently skip saving if actor is falsy' do
    Protocolist.actor = nil
    
    expect { Protocolist.fire :alarm }.not_to change{ Activity.count }
    expect { Protocolist.fire :alarm }.not_to raise_error
  end

  it 'should silently skip saving if activity_class is falsy' do
    Protocolist.activity_class = nil
    
    expect { Protocolist.fire :alarm }.not_to change{ Activity.count }
    expect { Protocolist.fire :alarm }.not_to raise_error
  end

  it 'should save a simple record' do
    expect { Protocolist.fire :alarm }.to change{ Activity.count }.by 1

    activity = Activity.last
    activity.actor.should         == actor
    activity.activity_type.should == :alarm
  end

  it 'should save a complex record' do
    expect do 
      Protocolist.fire :alarm, actor: another_actor, target: target, data: { foo: :bar }
    end.to change { Activity.count }.by 1

    activity = Activity.last    
    activity.actor.should         == another_actor
    activity.activity_type.should == :alarm
    activity.target.should        == target
    activity.data[:foo].should    == :bar
  end
end
