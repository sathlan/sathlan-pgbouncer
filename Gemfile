gemfile_local = File.join(File.dirname(__FILE__), '.gemfile')
if File.readable?(gemfile_local)
  puts "Loading #{gemfile_local}..." if $DEBUG
  instance_eval(File.read(gemfile_local))
end
