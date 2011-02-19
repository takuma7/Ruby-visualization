#!/usr/bin/ruby

require "socket"

sock = TCPSocket.open("localhost",10002)

while line = gets
  sock.write(line)
end