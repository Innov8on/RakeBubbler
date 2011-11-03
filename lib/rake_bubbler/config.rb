module RakeBubbler
  class Config
    attr_writer :tasks, :conditions, :executed

    def call_executed(name, duration, output, started, error)
      @executed.respond_to?(:call) && @executed.call(name, duration, output, started, error)
    end

    def tasks_include?(name)
      @tasks.respond_to?(:include?) && @tasks.include?(name)
    end

    def call_conditions
      !@conditions.respond_to?(:call) || @conditions.call
    end
  end
end
