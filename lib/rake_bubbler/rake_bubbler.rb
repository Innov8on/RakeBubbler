module RakeBubbler
  module RakeBubbler
    extend self

    @config = Config.new

    def config
      yield @config
    end

    def executed(name, duration, output, started, error)
      @config.call_executed(name, duration, output, started, error) 
    end

    def capture_task?(name)
      @config.tasks_include?(name) && @config.call_conditions
    end

    def capture_output
	    file = Tempfile.new(Digest::MD5.hexdigest((Time.now.to_i + rand(2**16)).to_s))
	
	    read, write = IO.pipe
	
	    save_stdout = $stdout.dup
	    $stdout.reopen(write)
	
	    if fork
	      read.close
	      yield
	      write.close
	      $stdout.reopen(save_stdout)
	      save_stdout.close
	      Process.wait
        file.unlink
	      file.read
	    else
	      write.close
	      $stdout.close
	      Shell.new.tee(file.path) < read > save_stdout
	      read.close
	      save_stdout.close
	      exit!
	    end  # fork
	  end  # capture_output

  end
end
