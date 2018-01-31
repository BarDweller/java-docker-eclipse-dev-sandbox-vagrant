# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.define "Sandbox" do |vm|
  end
  config.vm.provider "virtualbox" do |v|
    v.memory = 3072
    v.cpus = 2
    v.name = "Sandbox"
  end
  #Note.. need to install xauth too!
  config.ssh.forward_x11 = true

  #fix 'stdin is not a tty' output.
  config.vm.provision :shell, inline: "(grep -q -E '^mesg n$' /root/.profile && sed -i 's/^mesg n$/tty -s \\&\\& mesg n/g' /root/.profile && echo 'Ignore the previous error about stdin not being a tty. Fixing it now...') || exit 0;"

  # Run as Root -- install git, latest docker, bx cli
  config.vm.provision :shell, :inline => <<-EOT
    apt-get purge docker docker-engine docker.io
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    add-apt-repository -y ppa:webupd8team/atom
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    echo 'Installing Git,Sbt,Unzip,JDK & Curl'
    apt-get install -y \
      git \
      curl \
      sbt \
      unzip \
      xauth \
      atom \
      chromium-browser \
      openjdk-8-jdk
    echo 'Set up HTTPS repository'
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    echo 'Install Docker CE'
    apt-get update
    apt-get install -y docker-ce
    DOCKER_COMPOSE_VERSION=1.18.0
    curl -sSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo 'Add vagrant to docker group'
    usermod -aG docker vagrant
    ls -al /var/run/docker.sock
    chgrp docker /var/run/docker.sock
    chmod 775 /var/run/docker.sock
    if /usr/local/bin/bx > /dev/null
    then
      echo 'Updating Bluemix CLI'
      /usr/local/bin/bx update
    else
      echo 'Installing Bluemix CLI'
      sh <(curl -fssSL https://clis.ng.bluemix.net/install/linux 2>/dev/null)
    fi
    echo 'Installing maven'
    cd /opt
    wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
    tar -xvzf apache-maven-3.3.9-bin.tar.gz
    mv apache-maven-3.3.9 maven 
    rm apache-maven-3.3.9-bin.tar.gz
    cd /opt
    wget https://services.gradle.org/distributions/gradle-4.5-bin.zip
    unzip gradle-4.5-bin.zip
    rm gradle-4.5-bin.zip
    

    # create environment vars for all users.
    echo 'export M2_HOME=/opt/maven' | tee -a /etc/profile.d/maven.sh
    echo 'export PATH=${M2_HOME}/bin:${PATH}' | tee -a /etc/profile.d/maven.sh
    echo 'export GRADLE_HOME=/opt/gradle-4.5' | tee -a /etc/profile.d/gradle.sh
    echo 'export PATH=${GRADLE_HOME}/bin:${PATH}' | tee -a /etc/profile.d/gradle.sh
    # Indicate this is a vagrant VM
    echo 'export DOCKER_MACHINE_NAME=vagrant' | tee -a /etc/profile.d/docker_machine.sh
  EOT

  # Run as vagrant user (not yet in docker group): bx plugins, profile script
  config.vm.provision :shell, privileged: false, :inline => <<-EOT
    # Install eclipse.
    curl -k https://raw.githubusercontent.com/budhash/install-eclipse/master/install-eclipse > install-eclipse; chmod +x install-eclipse
    ./install-eclipse -p "http://download.eclipse.org/releases/neon,org.eclipse.jdt.feature.group" -p "http://download.eclipse.org/releases/neon,org.eclipse.linuxtools.docker.feature.group" -p"http://download.eclipse.org/tm/terminal/marketplace,org.eclipse.tm.terminal.feature.feature.group" eclipse

    PLUGINS=$(bx plugin list)
    if echo $PLUGINS | grep dev
    then
      /usr/local/bin/bx plugin update dev -r Bluemix
    else
      echo 'Installing Bluemix dev plugin'
      /usr/local/bin/bx plugin install dev -r Bluemix
    fi
    if echo $PLUGINS | grep container-service
    then
      /usr/local/bin/bx plugin update container-service -r Bluemix
    else
      echo 'Installing Bluemix container-service plugin'
      /usr/local/bin/bx plugin install container-service -r Bluemix
    fi
    if echo $PLUGINS | grep container-registry
    then
      /usr/local/bin/bx plugin update container-registry -r Bluemix
    else
      echo 'Installing Bluemix container-registry plugin'
      /usr/local/bin/bx plugin install container-registry -r Bluemix
    fi
    # Enable Gradle Daemon
    mkdir -p /home/vagrant/.gradle
    touch /home/vagrant/.gradle/gradle.properties
    echo "org.gradle.daemon=true" >> /home/vagrant/.gradle/gradle.properties

  EOT

  # Run as vagrant user: Always start things
  config.vm.provision :shell, privileged: false, run: "always", :inline => <<-EOT

    # Download and build lagom chirper
    git clone https://github.com/BarDweller/lagom-java-chirper-example.git
    cd lagom-java-chirper-example
    ./sbt-build -DbuildTarget=compose clean docker:publishLocal
    cd

    echo 'system is up, use vagrant ssh to access it.'
  EOT

end
