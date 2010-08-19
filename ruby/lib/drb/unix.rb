require 'socket'
require 'drb/drb'
require 'tmpdir'

raise(LoadError, "UNIXServer is required") unless defined?(UNIXServer)

module DRb

  class DRbUNIXSocket < DRbTCPSocket
    def self.parse_uri(uri)
      if /^drbunix:(.*?)(\?(.*))?$/ =~ uri
	filename = $1
	option = $3
	[filename, option]
      else
	raise(DRbBadScheme, uri) unless uri =~ /^drbunix:/
	raise(DRbBadURI, 'can\'t parse uri:' + uri)
      end
    end

    def self.open(uri, config)
      filename, option = parse_uri(uri)
      filename.untaint
      soc = UNIXSocket.open(filename)
      self.new(uri, soc, config)
    end

    def self.open_server(uri, config)
      filename, option = parse_uri(uri)
      if filename.size == 0
	soc = temp_server
        filename = soc.path
	uri = 'drbunix:' + soc.path
      else
	soc = UNIXServer.open(filename)
      end
      owner = config[:UNIXFileOwner]
      group = config[:UNIXFileGroup]
      if owner || group
        require 'etc'
        owner = Etc.getpwnam( owner ).uid  if owner
        group = Etc.getgrnam( group ).gid  if group
        File.chown owner, group, filename
      end
      mode = config[:UNIXFileMode]
      File.chmod(mode, filename) if mode

      self.new(uri, soc, config, true)
    end

    def self.uri_option(uri, config)
      filename, option = parse_uri(uri)
      return "drbunix:#{filename}", option
    end

    def initialize(uri, soc, config={}, server_mode = false)
      super(uri, soc, config)
      set_sockopt(@socket)
      @server_mode = server_mode
      @acl = nil
    end

    # import from tempfile.rb
    Max_try = 10
    private
    def self.temp_server
      tmpdir = Dir::tmpdir
      n = 0
      while true
	begin
	  tmpname = sprintf('%s/druby%d.%d', tmpdir, $$, n)
	  lock = tmpname + '.lock'
	  unless File.exist?(tmpname) or File.exist?(lock)
	    Dir.mkdir(lock)
	    break
	  end
	rescue
	  raise "cannot generate tempfile `%s'" % tmpname if n >= Max_try
	  #sleep(1)
	end
	n += 1
      end
      soc = UNIXServer.new(tmpname)
      Dir.rmdir(lock)
      soc
    end

    public
    def close
      return unless @socket
      path = @socket.path if @server_mode
      @socket.close
      File.unlink(path) if @server_mode
      @socket = nil
    end

    def accept
      s = @socket.accept
      self.class.new(nil, s, @config)
    end

    def set_sockopt(soc)
      soc.fcntl(Fcntl::F_SETFL, Fcntl::FD_CLOEXEC) if defined? Fcntl::FD_CLOEXEC
    end
  end

  DRbProtocol.add_protocol(DRbUNIXSocket)
end
