BEGIN {
  no warnings qw ( uninitialized );
  print "1..1\n";
  eval "use OpenFrame::Server::Apache";
  if ($@) {
    print "not ok 1\n";
    if ($ARGV[0] eq '+OUTPUT') {
      warn($@);
    }
  } else {
    print "ok 1\n";
  }
}
