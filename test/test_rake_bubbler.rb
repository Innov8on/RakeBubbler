require 'helper'

class TestRakeBubbler < Test::Unit::TestCase
  extend Rake::DSL

  task(:bubbler_task1){ puts "Task 1"; sleep 1; }
  task(:bubbler_task2, [:arg1] => :bubbler_task1){ puts "Task 2" }
  task(:error_task){ puts "Error task"; raise 'Help me!!!' }

  context 'executed block' do
    setup do
	    @run = 0
	    @name, @duration, @output, @started, @error = nil
	  
	    @executed_proc = Proc.new do |p_name, p_duration, p_output, p_started, p_error|
	      @run += 1
	      @name      = p_name
	      @duration  = p_duration
	      @output    = p_output
	      @started   = p_started
        @error     = p_error
	    end
    end

	  should 'should be executed if no error' do
	    config(['bubbler_task2'], nil, @executed_proc) 
	    Rake::Task['bubbler_task2'].invoke('10')
	
	    assert_equal 1, @run
	    assert_equal "Task 1\nTask 2\n", @output
	    assert_operator @duration, :>, 0
	    assert_kind_of Time, @started
	    assert_equal 'bubbler_task2', @name
      assert_nil @error
	  end

    should 'be executed if error' do
	    config(['error_task'], nil, @executed_proc)
      
      assert_raise(RuntimeError) do
	      Rake::Task['error_task'].invoke
      end
	
	    assert_equal 1, @run
	    assert_equal "Error task\n", @output
	    assert_operator @duration, :>, 0
	    assert_kind_of Time, @started
	    assert_equal 'error_task', @name
      assert_not_nil @error
    end
  end # end context executed block

  context '.capture_task?' do
    should 'return true if task is included on the list' do
      config(['bubbler_task1'])
      assert RakeBubbler::RakeBubbler.capture_task?('bubbler_task1')
    end

    should 'return false if conditions are not met' do
      config(['bubbler_task1'], Proc.new{false})
      assert !RakeBubbler::RakeBubbler.capture_task?('bubbler_task1')
    end

    should 'return false if task is not on the list' do
      config()
      assert !RakeBubbler::RakeBubbler.capture_task?('bubbler_task1')
    end
  end # end context .capture_task?

  private

  def config(tasks = nil, conditions = nil, executed = nil)
		RakeBubbler::RakeBubbler.config do |config|
		  config.tasks        = tasks
		  config.conditions   = conditions
		  config.executed     = executed
		end
  end
end
