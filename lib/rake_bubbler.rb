require 'rake'

require 'rake_bubbler/config'
require 'rake_bubbler/bubble_task'
require 'rake_bubbler/rake_bubbler'

Rake::Task.class_eval do
  include RakeBubbler::BubbleTask
end
