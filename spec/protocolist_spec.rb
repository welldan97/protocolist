require "spec_helper"

class User < SuperModel::Base

end

class Activity < SuperModel::Base

end

describe Protocolist do
  before :each do
    Activity.destroy_all
    @subject = User.new(:name => 'Bill')
    Protocolist.subject = @subject
    Protocolist.activity_class = Activity
  end

  it 'should silently skip saving if subject is falsy' do
    Protocolist.subject = nil
    expect {Protocolist.fire :alarm}.not_to change{Activity.count}
    expect {Protocolist.fire :alarm}.not_to raise_error
  end

  it 'should silently skip saving if activity_class is falsy' do
    Protocolist.activity_class = nil
    expect {Protocolist.fire :alarm}.not_to change{Activity.count}
    expect {Protocolist.fire :alarm}.not_to raise_error
  end

  it 'should save a simple record' do
    expect {Protocolist.fire :alarm}.to change{Activity.count}.by 1

    Activity.last.subject.should == @subject
    Activity.last.activity_type.should == :alarm
  end

  it 'should save a complex record' do
    another_subject = User.new(:name => 'Bob')
    target = User.new(:name => 'Mary')

    expect {
      Protocolist.fire :alarm,
      :subject => another_subject,
      :target => target,
      :data => {:some_attr => :some_data}
    }.to change{Activity.count}.by 1

    Activity.last.subject.name.should == 'Bob'
    Activity.last.activity_type.should == :alarm
    Activity.last.target.name.should == 'Mary'
    Activity.last.data[:some_attr].should == :some_data
  end
end
