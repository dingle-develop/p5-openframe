package OpenFrame::Server::HTTP;

use strict;
use CGI;
use CGI::Cookie;
use File::Temp qw(tempfile);
use HTTP::Daemon;
use HTTP::Status;
use OpenFrame::AbstractCookie;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;
use OpenFrame::Constants;
use OpenFrame::Server;
use Scalar::Util qw(blessed);
use URI;

our $VERSION = '1.11';

# Ideas from http://www.stonehenge.com/merlyn/WebTechniques/col34.listing.txt
my $MAXCLIENTS = 8;
my $MAXREQUESTSPERCLIENT = 200;

sub new {
  my $class = shift;
  my %config = @_;

  my $self = {};
  $self->{_port} = $config{port} || 8000;

  bless $self, $class;

  setup_signals();

  return $self;
}


sub handle {
  my $self = shift;

  my $port = $self->{_port};

  my %kids;

  my $master = HTTP::Daemon->new(LocalPort => $port, Reuse => 1, ReuseAddr => 1)
      or die "Cannot create master: $!";
  for (1..$MAXCLIENTS) {
    $kids{&fork_a_slave($master)} = "slave";
  }
  {                             # forever:
    my $pid = wait;
    my $was = delete ($kids{$pid}) || "?unknown?";
    if ($was eq "slave") {      # oops, lost a slave
      sleep 1;                  # don't replace it right away (avoid thrash)
      $kids{&fork_a_slave($master)} = "slave";
    }
  } continue { redo };          # semicolon for cperl-mode
}

sub setup_signals {             # return void
  setpgrp;                      # I *am* the leader
  $SIG{HUP} = $SIG{INT} = $SIG{TERM} = sub {
    my $sig = shift;
    $SIG{$sig} = 'IGNORE';
    kill $sig, 0;               # death to all-comers
    exit;
  };
}

sub fork_a_slave {              # return int (pid)
  my $master = shift;           # HTTP::Daemon

  my $pid;
  defined ($pid = fork) or die "Cannot fork: $!";
  &child_does($master) unless $pid;
  $pid;
}

sub child_does {                # return void
  my $master = shift;           # HTTP::Daemon

  my $did = 0;                  # processed count

  {
    flock($master, 2);          # LOCK_EX
    my $slave = $master->accept or die "accept: $!";
    flock($master, 8);          # LOCK_UN
    my @start_times = (times, time);
    $slave->autoflush(1);
    &handle_one_connection($slave); # closes $slave at right time
  } continue { redo if ++$did < $MAXREQUESTSPERCLIENT };
  exit 0;
}

sub handle_one_connection {
  my $c = shift;

  my $r = $c->get_request;
  return unless defined $r;

  my ($args) = parse_request($r);

  my $cookietin  = OpenFrame::AbstractCookie->new();

  if ($r->header('Cookie')) {
    foreach my $ctext (split /; ?/, $r->header('Cookie')) {
      my($cname, $cvalue) = split /=/, $ctext;
      $cookietin->set($cname, $cvalue);
    }
  }

  my $abstractRequest = OpenFrame::AbstractRequest->new(
							uri         => $r->uri,
							descriptive => 'web',
							arguments   => $args,
							cookies     => $cookietin,
						       );
  my $http_response;

  my $response = OpenFrame::Server->action($abstractRequest, OpenFrame::Config->new());
  my $newcookietin = $response->cookies();
  if ($response->code == ofOK) {
    my $h = HTTP::Headers->new();
    my %cookies = $newcookietin->get_all;
    foreach my $name (keys %cookies) {
      my $cookie = CGI::Cookie->new(-name    =>  $name,
				    -value   =>  $cookies{$name},
				    -expires =>  '+1M');
      $h->header('Set-Cookie' => "$cookie");
    }
    $h->content_type($response->mimetype() || 'text/html');
    $http_response = HTTP::Response->new(RC_OK, undef, $h, $response->message);
  } else {
    my $html = qq|<html><head><title>OpenFrame Error</title></head>
<body><h1>OpenFrame Error</h1><p>| . $response->message() . qq|</body></html>|;
    $http_response = HTTP::Response->new(RC_INTERNAL_SERVER_ERROR, "OpenFrame error", HTTP::Headers->new(), $html);
  }
  $c->send_response($http_response);
  close $c;
}

sub parse_request {
  my $r = shift;
  my $args = {};

  my $method = $r->method;

  if ($method eq 'GET' || $method eq 'HEAD') {
    my $cgi = CGI->new($r->uri->equery);
    $args = { map { ($_, $cgi->param($_)) } $cgi->param() };
    $r->uri->query(undef);
  } elsif ($method eq 'POST') {
    my $content_type = $r->content_type;

    if (!$content_type || $content_type eq "application/x-www-form-urlencoded") {
      my $cgi = CGI->new($r->content);
      $args = { map { ($_, $cgi->param($_)) } $cgi->param() }; 
      $r->uri->query(undef);
    } elsif ($content_type eq "multipart/form-data") {
      $args = parse_multipart_data($r);
    } else {
      warn "[server:http] invalid content type: $content_type";
    }
  } else {
    warn "[server::http] unsupported method: $method";
  }
  return $args;
}

sub parse_multipart_data {
  my $r = shift;
  my $args = {};

  my($boundary) = $r->headers->header("Content-Type") =~ /boundary=(\S+)$/;

  foreach my $part (split(/-?-?$boundary-?-?/, $r->content)) {
    $part =~ s|^\r\n||g;
    next unless $part;
    my %headers;
    my @lines = split /\r\n/, $part;
    while (@lines) {
      my $line = shift @lines;
      last unless $line;
      $headers{type} = $1 if $line =~ /^content-type: (.+)$/i;
      $headers{disposition} = $1 if $line =~ /^content-disposition: (.+)$/i;
    }
    my $name = $1 if $headers{disposition} =~ /name="(.+?)"/;
    my $value = join("\n", @lines);
    if ($headers{disposition} =~ /filename=".+?"/) {
      my $fh = tempfile(DIR => "/tmp/", UNLINK => 1);
      print $fh $value;
      $fh->seek(0, 0);
      $args->{$name} = $fh;
    } else {
      $args->{$name} = $value;
    }
  }

  return $args;
}

1;

__END__

=head1 NAME

OpenFrame::Server::HTTP - Provide standalone HTTP access to OpenFrame

=head1 SYNOPSIS

  use OpenFrame::Server::HTTP;
  my $h = OpenFrame::Server::HTTP->new(port => 8000);
  $h->handle();

=head1 DESCRIPTION

C<OpenFrame::Server::HTTP> provides a standalone webserver which gives
web access to an OpenFrame application (without having to set up
Apache). The port that the webserver listens on is set by the value of
the port key in the configuration, although it defaults to port 8000.

=head1 NOTES

This module requires HTTP::Daemon to be installed, and supports HTTP
1.1 (including keepalives) and does preforking to process multiple
requests at the same time.

Note that any file upload objects are in the arguments of the
AbstractRequest and their value is a filehandle pointing to the
object.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=cut
