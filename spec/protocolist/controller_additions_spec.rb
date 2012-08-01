require "spec_helper"

class FirestartersController
  #stub before filter
  def self.before_filter *args
  end

  include Protocolist::ControllerAdditions

  def explicit_use(target, data)
    fire :gogogo, target: target, data: data
  end

  def implicit_use(target)
    @firestarter = target
    fire
  end
end

describe Protocolist::ControllerAdditions do
  let(:controller) { FirestartersController.new }
  let(:actor) { User.new(name: 'Bill') }
  let(:lisa)  { User.new(name: 'Lisa') }
  let(:mary)  { User.new(name: 'Mary') }

  before :each do
    Activity.destroy_all

    controller.stub(:current_user).and_return(actor)
    controller.stub(:controller_name).and_return('firestarters')
    controller.stub(:action_name).and_return('quick_and_dirty_action_stub')
    controller.stub(:params).and_return('les params')

    controller.initialize_protocolist
  end

  describe 'direct fire method call' do
    it 'saves record with target and data when called explicitly' do
      controller.explicit_use(lisa, '<3 <3 <3')

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :gogogo
      activity.target.should        == lisa
      activity.data.should          == '<3 <3 <3'
    end

    it 'saves record with target and data when called implicitly' do
      controller.implicit_use(mary)

      activity = Activity.last
      activity.actor.should         == actor
      activity.activity_type.should == :quick_and_dirty_action_stub
      activity.target.should        == mary
    end
  end

  describe 'fires callback' do
    it 'saves record when called with minimal options' do
      FirestartersController.should_receive(:after_filter) do |callback_proc, options|
        options[:only].should == :download
        expect { callback_proc.call(controller) }.to change { Activity.count }.by(1)

        activity = Activity.last
        activity.actor.should         == actor
        activity.activity_type.should == :download
        activity.target.should_not be
      end

      FirestartersController.send(:fires, :download)
    end

    it 'saves record when called with complex options' do
      FirestartersController.should_receive(:after_filter) do |callback_proc, options|
        options[:only].should == [:download_report, :download_file, :download_map]
        options[:if].should   == 'if condition'

        expect { callback_proc.call(controller) }.to change { Activity.count }.by(1)

        activity = Activity.last
        activity.actor.should         == actor
        activity.activity_type.should == :download
        activity.data.should          == 'les params'
        activity.target.should_not be
      end

      FirestartersController.send(:fires, :download,
        only: [:download_report, :download_file, :download_map],
        data: ->(c) { c.params }, if: 'if condition'
      )
    end
  end
end
