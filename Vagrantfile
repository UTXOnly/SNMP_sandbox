Vagrant.configure("2") do |config|
  config.vm.box = "uwbbi/bionic-arm64"
  config.vm.network "forwarded_port", guest: 8125, host: 8125, auto_correct: true
  #config.vm.provider "vmware_fusion" do |v|
  config.vm.provider 'virtualbox' do |v|
  end

  config.vm.synced_folder "./data", "/data", create: true
  config.vm.provision :file, source: "./test_profile.yaml", destination: "/home/vagrant/test_profile.yaml"
  config.vm.provision :file, source: '~/.sandbox.conf.sh', destination: '/home/vagrant/.sandbox.conf.sh'
  config.vm.provision :file, source: './conf.yaml', destination: '/home/vagrant/conf.yaml'
  config.vm.provision "shell", path: "setup.sh"
end
