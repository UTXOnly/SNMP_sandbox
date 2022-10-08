Vagrant.configure("2") do |config|
  config.vm.box = "uwbbi/bionic-arm64"

  #config.vm.provider "vmware_fusion" do |v|
  config.vm.provider 'vmware_fusion' do |v|
  end

  config.vm.synced_folder "./data", "/data", create: true
  config.vm.provision :file, source: '~/.sandbox.conf.sh', destination: '/home/vagrant/.sandbox.conf.sh'
  config.vm.provision "shell", path: "./setup.sh"
end