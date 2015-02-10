
require "run_after_commit"

begin
  require "minitest"

  class RunAfterCommit::TestCase < MiniTest::Test; end 
rescue LoadError
  require "minitest/unit"

  class RunAfterCommit::TestCase < MiniTest::Unit::TestCase; end 
end

require "minitest/autorun"
require "active_record"
require "yaml"

DATABASE = ENV["DATABASE"] || "sqlite"

ActiveRecord::Base.establish_connection YAML.load_file(File.expand_path("../database.yml", __FILE__))[DATABASE]

class TestModel < ActiveRecord::Base
  include RunAfterCommit

  def after_save(&block)
    after_save_queue << block
  end

  after_save :run_after_save_queue

  def run_after_save_queue
    after_save_queue.each do |block|
      instance_eval(&block)
    end
  ensure
    clear_after_save_queue
  end

  def after_save_queue
    @after_save_queue ||= []
  end

  def clear_after_save_queue
    @after_save_queue = []
  end
end

ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS test_models"

ActiveRecord::Base.connection.create_table :test_models do |t|
  t.string :title
end

