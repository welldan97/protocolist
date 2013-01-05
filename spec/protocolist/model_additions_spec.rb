require "spec_helper"

class Firestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  def delete
    fire :delete, target: false
  end

  def myself
    fire :myself
  end

  def love_letter_for_mary(target, data)
    fire :love_letter, target: target, data: data
  end
end

class SimpleFirestarter < SuperModel::Base
  include Protocolist::ModelAdditions
  fires :create
end

class ConditionalFirestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  fires :i_will_be_saved, on: :create, if: :return_true_please
  fires :and_i_won_t,     on: :create, if: :return_false_please

  def return_false_please
    false
  end

  def return_true_please
    true
  end
end

class ComplexFirestarter < SuperModel::Base
  include Protocolist::ModelAdditions

  fires :yohoho, on: [:create, :destroy], target: false, data: :hi
  fires :yohoho, on: :update, data: 'name * 2'

  def hi
    'Hi!'
  end
end

describe Protocolist::ModelAdditions do
  let(:actor) { User.new(name: 'Bill') }
  let(:mary) { User.new(name: 'Mary') }

  before do
    Activity.destroy_all

    Protocolist.actor = actor
    Protocolist.activity_class = Activity
  end

  describe 'direct fire method call' do
    let(:firestarter) { Firestarter.new }

    it 'saves record with target and data' do
      expect { firestarter.love_letter_for_mary(mary, '<3 <3 <3') }.to change { Activity.count }.by(1)

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :love_letter
      activity.target.should        == mary
      activity.data.should          == '<3 <3 <3'
    end

    it 'saves record with self as target if target is not set' do
      expect { firestarter.myself }.to change { Activity.count }.by(1)

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :myself
      activity.target.should        == firestarter
    end

    it 'saves record without target if target set to false' do
      expect { firestarter.delete }.to change { Activity.count }.by(1)

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :delete
      activity.target.should        be_false
    end
  end

  describe 'fires callback' do
    it 'saves record when called with minimal options' do
      expect { SimpleFirestarter.create(name: 'Ted') }.to change { Activity.count }.by(1)

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :create
      activity.target.name.should   == 'Ted'
    end

    it 'saves record when called with complex options' do

      #first create record

      expect { ComplexFirestarter.create(name: 'Ted') }.to change { Activity.count }.by(1)

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :yohoho
      activity.target.should_not be
      activity.data.should == 'Hi!'

      #then destroy record

      expect { ComplexFirestarter.last.destroy }.to change { Activity.count }.by(1)

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :yohoho
      activity.target.should_not be
      activity.data.should == 'Hi!'
    end

    it 'saves record with string data attribute parsed' do
      ComplexFirestarter.create(name: 'Ted')
      ComplexFirestarter.last.update_attributes name: 'Bob'

      activity = Activity.last
      activity.data.should == 'BobBob'
    end

    it 'saves checks conditions' do
      expect { ConditionalFirestarter.create(name: 'Ted') }.to change { Activity.count }.by(1)

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :i_will_be_saved
    end
  end
end
