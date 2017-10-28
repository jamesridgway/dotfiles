FROM ubuntu:16.04
MAINTAINER James Ridgway <myself@james-ridgway.co.uk>

RUN apt-get -qq update
RUN apt-get install git sudo zsh  -qq -y

RUN useradd -m -s /bin/zsh tester
RUN usermod -aG sudo tester
RUN echo "tester   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers

ADD . /home/tester/projects/dotfiles
RUN chown -R tester:tester /home/tester

USER tester
RUN mkdir -p /home/tester/projects

ENV HOME /home/tester
WORKDIR /home/tester/projects/dotfiles

RUN ./setup
