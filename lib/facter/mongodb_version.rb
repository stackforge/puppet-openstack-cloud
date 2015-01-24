# For Debian / Ubuntu
if FileTest.exists?("/usr/bin/dpkg-query")
  Facter.add("mongodb_version") do
    setcode do
      %x{/usr/bin/dpkg-query -W -f='${Version}' mongodb-10gen}
    end
  end
end

# For RHEL / CentOS
if FileTest.exists?("/usr/bin/rpm")
  Facter.add("mongodb_version") do
    setcode do
      %x{/bin/rpm -q --queryformat "%{VERSION}-%{RELEASE}" mongodb-server}
    end
  end
end
