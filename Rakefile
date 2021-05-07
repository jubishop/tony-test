require 'rakegem'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop)
RakeGem::Task.new

task default: %w[rubocop:auto_correct]
