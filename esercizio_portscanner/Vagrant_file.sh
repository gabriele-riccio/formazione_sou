Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  # VM 1: Lo Scanner
  config.vm.define "scanner" do |scanner|
    scanner.vm.hostname = "scanner"
    scanner.vm.network "private_network", ip: "192.168.50.10"
  end

  # VM 2: Il Bersaglio (Target)
  config.vm.define "target" do |target|
    target.vm.hostname = "target"
    target.vm.network "private_network", ip: "192.168.50.11"

    # Port forwarding
    target.vm.network "forwarded_port", guest: 80,  host: 8080
    target.vm.network "forwarded_port", guest: 443, host: 8443
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

end
