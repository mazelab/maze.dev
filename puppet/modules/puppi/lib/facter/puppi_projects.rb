require 'facter'
Facter.add("puppi_projects") do
  setcode do
    Facter::Util::Resolution.exec('ls `grep projectsdir  /etc/puppi/puppi.conf | sed \'s/projectsdir="\([^"]*\)"/\1/\'` | tr \'\n\' \',\' | sed \'s/,$//\'')
  end
end
