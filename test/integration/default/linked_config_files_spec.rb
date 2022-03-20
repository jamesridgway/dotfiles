{
    'gnupg/gpg.conf' => '.gnupg/gpg.conf',
    'gnupg/scd-event' => '.gnupg/scd-event',
    'vim/.vimrc' => '.vimrc',
    'tmux/.tmux.conf' => '.tmux.conf',
    'gnome/gtk-3.0/gtk.css' => '.config/gtk-3.0/gtk.css',
    'fonts' => '.fonts',
    'gradle/gradle.properties' => '.gradle/gradle.properties',
    'zsh/.zshrc' => '.zshrc',
    'zsh/.zshenv' => '.zshenv',
    'zsh/custom/themes/jagnoster.zsh-theme' => '.oh-my-zsh/custom/themes/jagnoster.zsh-theme',
}.each do |source, destination|
  describe file("/home/ubuntu/#{destination}") do
    its('link_path') { should eq "/home/ubuntu/data/#{source}" }
  end
end
