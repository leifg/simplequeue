watch( 'test/test_.*\.rb' )  {|md| system("ruby #{md[0]}") }
watch( 'lib/(.*)\.rb' )      {|md| system("ruby test/test_#{md[1]}.rb") }