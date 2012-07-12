require "spec_helper"

class User < SuperModel::Base

end

class Activity < SuperModel::Base

end

describe Protocolist do
  before :each do
    Activity.destroy_all
    @actor = User.new(:name => 'Bill')
    Protocolist.actor = @actor
    Protocolist.activity_class = Activity
  end

  it 'should silently skip saving if actor is falsy' do
    Protocolist.actor = nil
    expect {Protocolist.fire :alarm}.not_to change{Activity.count}
    expect {Protocolist.fire :alarm}.not_to raise_error
  end

  it 'should not silently skip saving if activity_class is falsy' do
    Protocolist.activity_class = nil
    expect {Protocolist.fire :alarm}.to change{Activity.count}.by 1
    expect {Protocolist.fire :alarm}.not_to raise_error
  end

  it 'should save a record when activity_class is falsy' do
    Protocolist.activity_class = nil

    expect {Protocolist.fire :alarm}.to change{Activity.count}.by 1

    Activity.last.actor.should == @actor
    Activity.last.activity_type.should == :alarm
  end

  it 'should allow to pass :actor as a custom parameter' do
    expect {
      Protocolist.fire :alarm,
                       :actor => User.new(:name => 'Bob')
    }.to change{Activity.count}.by 1

    Activity.last.actor.name.should == 'Bob'
    Activity.last.activity_type.should == :alarm
  end

  it 'should save a simple record' do
    expect {Protocolist.fire :alarm}.to change{Activity.count}.by 1

    Activity.last.actor.should == @actor
    Activity.last.activity_type.should == :alarm
  end

  it 'should save a complex record' do
    another_actor = User.new(:name => 'Bob')
    target = User.new(:name => 'Mary')

    expect {
      Protocolist.fire :alarm,
      :actor => another_actor,
      :target => target,
      :data => {:some_attr => :some_data}
    }.to change{Activity.count}.by 1

    Activity.last.actor.name.should == 'Bob'
    Activity.last.activity_type.should == :alarm
    Activity.last.target.name.should == 'Mary'
    Activity.last.data[:some_attr].should == :some_data
  end
end
