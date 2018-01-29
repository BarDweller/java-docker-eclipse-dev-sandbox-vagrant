# java-docker-eclipse-dev-sandbox-vagrant
A Vagrantfile to build a development sandbox image for java.

Tools:
- git
- maven, gradle, sbt
- bx commands for IBM Cloud
- docker
- docker-compose
- Eclipse
  - Terminal plugin
  - Docker plugin
  - Java Development plugin
- xauth

`vagrant up`
Launches the sandbox.

`vagrant ssh`
Ssh's into the sandbox, with X11 forwarding active. 
(you'll need a local x11 server of some type.. )

`./eclipse/eclipse`
Launches the eclipse installed.


