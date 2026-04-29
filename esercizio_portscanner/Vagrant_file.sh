Vagrant.configure("2") do |config|
  # Ho usato un'immagine Linux standard (es Ubuntu)
  config.vm.box = "bento/ubuntu-20.04"

  # VM 1: La prima virtual machine è lo  Scanner
  config.vm.define "scanner" do |scanner|
    scanner.vm.hostname = "scanner"
    scanner.vm.network "private_network", ip: "192.168.50.10"
  end

  # VM 2: La seconda virtualmachine è il target o bersaglio
  config.vm.define "target" do |target|
    target.vm.hostname = "target"
    target.vm.network "private_network", ip: "192.168.50.11"
  end
  config.vm.provider "virtualbox" do |vb|
    # Qui ho personalizzato la VM, ad esempio ho assegnato  1GB di RAM
    vb.memory = "1024"

end
