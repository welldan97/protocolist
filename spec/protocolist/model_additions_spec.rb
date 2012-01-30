require "spec_helper"

class User < SuperModel::Base
  
end

class Activity < SuperModel::Base
  
end

class Comment < SuperModel::Base
  
  def delete
    fire :delete, :data => false
  end
  
  def myself
    fire :myself
  end
  
  def very_important_data
    fire :very_important_data, :data => 'very important data'
  end
end

describe Protocolist::ModelAdditions do
  describe 'direct fire method call' do
    it 'saves record with data' do
    end
    
    it 'saves record with data = self if data not set' do
    end
    
    it 'saves record without data if data set to false' do
    end
  end
  
end
