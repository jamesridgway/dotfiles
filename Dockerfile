FROM ubuntu:16.04
MAINTAINER James Ridgway <myself@james-ridgway.co.uk>

# OS updates and install
RUN apt-get -qq update
RUN apt-get install git sudo zsh -qq -y

# Create test user and add to sudoers
RUN useradd -m -s /bin/zsh tester
RUN usermod -aG sudo tester
RUN echo "tester   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers

# Add dotfiles and chown
ADD . /home/tester/projects/dotfiles
RUN chown -R tester:tester /home/tester

# Switch testuser
USER tester
ENV HOME /home/tester

# Change working directory
WORKDIR /home/tester/projects/dotfiles

# Run setup
RUN ./setup
