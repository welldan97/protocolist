require "spec_helper"

class User < SuperModel::Base

end

class Activity < SuperModel::Base
  attributes :data, :language_key, :secondary_target_type, :secondary_target_id
end

class FirestartersController
  #stub before filter
  def self.before_filter *args
  end

  include Protocolist::ControllerAdditions
  def explicit_use
    fire :gogogo, :target => User.new(:name => 'Lisa'), :data => '<3 <3 <3'
  end

  def implicit_use
    @firestarter = User.new(:name => 'Marge')
    fire
  end

  def custom_attributes_use
    fire :gogogo, :target => User.new(:name => 'Lisa'),  :secondary_target => User.new(:name => 'Admin'), :data => '<3 <3 <3'
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
    @controller.stub(:params){'les params'}

    @controller.initilize_protocolist
  end

  describe 'direct fire method call' do
    it 'saves record with target and data when called explicitly' do
      @controller.explicit_use

      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :gogogo
      Activity.last.target.name.should == 'Lisa'
      Activity.last.data.should == '<3 <3 <3'
    end

    it 'saves record with target and data when called implicitly' do
      @controller.implicit_use

      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :quick_and_dirty_action_stub
      Activity.last.target.name.should == 'Marge'
    end

    it 'saves record with target and data when called with custom attributes' do
      @controller.custom_attributes_use

      Activity.last.actor.name.should == 'Bill'
      Activity.last.activity_type.should == :gogogo
      Activity.last.target.name.should == 'Lisa'
      Activity.last.secondary_target.name.should == 'Admin'
    end
  end

  describe 'fires callback' do
    it 'saves record when called with minimal options' do
      FirestartersController.should_receive(:after_filter) do |callback_proc, options|
        options[:only].should == :download

        expect {
          callback_proc.call(@controller)
        }.to change{Activity.count}.by 1
        Activity.last.actor.name.should == 'Bill'
        Activity.last.activity_type.should == :download
        Activity.last.target.should_not be
      end
      FirestartersController.send(:fires, :download)
    end

    it 'saves record when called with complex options' do
      FirestartersController.should_receive(:after_filter) do |callback_proc, options|
        options[:only].should == [:download_report, :download_file, :download_map]
        options[:if].should == 'if condition'

        expect {
          callback_proc.call(@controller)
        }.to change{Activity.count}.by 1

        Activity.last.actor.name.should == 'Bill'
        Activity.last.activity_type.should == :download
        Activity.last.data.should == 'les params'
        Activity.last.target.should_not be
      end

      FirestartersController.send(:fires, :download,
                                  :only => [:download_report, :download_file, :download_map],
                                  :data => lambda{|c| c.params },
                                  :if => 'if condition')
    end

    it 'saves record when called with even more complex options' do
      FirestartersController.should_receive(:after_filter) do |callback_proc, options|
        options[:only].should == [:download_report, :download_file, :download_map]
        options[:if].should == 'if condition'

        expect {
          callback_proc.call(@controller)
        }.to change{Activity.count}.by 1

        Activity.last.actor.name.should == 'Bill'
        Activity.last.activity_type.should == :download
        Activity.last.data.should == 'les params'
        Activity.last.secondary_target.name.should == 'Admin'
        Activity.last.target.should_not be
      end

      FirestartersController.send(:fires, :download,
                                  :only => [:download_report, :download_file, :download_map],
                                  :data => lambda{|c| c.params },
                                  :language_key => 'en',
                                  :secondary_target => User.new(:name => 'Admin'),
                                  :if => 'if condition')
    end
  end
end
