[3300, 3301].each do |mysql_port|
  describe port(mysql_port) do
    it { should be_listening }
    its('protocols') { should include('tcp') }
  end
end
