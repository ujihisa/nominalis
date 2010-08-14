describe 'nominalis' do
  it 'compiles' do
    `./bin/nominalis -e 'print_r [1]'`.should == "print_r(array(1));\n"
  end
end
