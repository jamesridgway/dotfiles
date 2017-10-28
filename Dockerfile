FROM ubuntu:16.04
MAINTAINER James Ridgway <myself@james-ridgway.co.uk>

RUN apt-get -qq update
RUN apt-get install git -qq -y

RUN useradd -m tester
USER tester

RUN mkdir -p /home/tester/projects
ADD . /home/tester/projects/dotfiles

ENV HOME /home/tester
WORKDIR /home/tester

RUN /home/tester/projects/dotfiles/setup
