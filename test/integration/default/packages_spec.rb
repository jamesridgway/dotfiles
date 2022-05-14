%w(autojump curl htop python3 pip3 vim zsh).each do |cmd|
  describe command(cmd) do
    it { should exist }
  end
end
