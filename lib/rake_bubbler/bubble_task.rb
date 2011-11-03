require 'benchmark'
require 'digest/md5'
require 'shell'
require 'tempfile'

module RakeBubbler
  module BubbleTask

    def self.included(klass)
      klass.class_eval do

        def invoke_with_output_capture(*params)
          return invoke_without_output_capture(*params) unless RakeBubbler.capture_task?(name)
    
          duration, error = nil
          started = Time.now
    
          # capture task output
          output = RakeBubbler.capture_output do
            time = Benchmark.measure(name) do
              begin
                # invoke task
                invoke_without_output_capture(*params)
              rescue Exception => e
                error = e
              end
            end
    
            duration = time.real
          end
    
          RakeBubbler.executed(name, duration, output, started, error)
          raise error if error
        end  # invoke_with_output_capture

        alias_method :invoke_without_output_capture, :invoke
        alias_method :invoke, :invoke_with_output_capture 

      end
    end
    
  end  # BubbleTask 
end # RakeBubbler
