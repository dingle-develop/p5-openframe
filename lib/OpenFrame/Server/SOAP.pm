package OpenFrame::Server::SOAP;

use strict;
use SOAP::Transport::HTTP;
#use SOAP::Lite +trace => 'all';
use OpenFrame::Server::Direct;

our $VERSION = '1.00';

sub new {
  my $class = shift;
  my %config = @_;

  my $self = {};
  $self->{_port} = $config{port} || 8010;

  bless $self, $class;
  return $self;
}


sub handle {
  my $self = shift;
  my $port = $self->{_port};

  SOAP::Transport::HTTP::Daemon
  ->new(LocalPort => $port, Reuse => 1, ReuseAddr => 1)
  ->dispatch_to('OpenFrame::Server::Direct', 'OpenFrame::AbstractResponse')
  ->handle;
}


1;

__END__

=head1 NAME

OpenFrame::Server::SOAP - Provide SOAP access to OpenFrame

=head1 SYNOPSIS

  # in the server:
  use OpenFrame::Server::SOAP;
  my $h = OpenFrame::Server::SOAP->new(port => 8010);
  $h->handle();

  # in the client:
  use SOAP::Lite +autodispatch =>
    uri => 'http://localhost:8010/',
    proxy => 'http://localhost:8010/';

  my $url = "http://localhost/myapp/?param=5";
  my $cookietin = OpenFrame::AbstractCookie->new();
  my $direct = OpenFrame::Server::Direct->new();

  my $response;
  ($response, $cookietin) = $direct->handle($url, $cookietin);

  if ($response->code() == ofOK) {
    print $response->message() . "\n";
  } else {
    print "Some sort of error. Drat.\n";
  }

=head1 DESCRIPTION

C<OpenFrame::Server::SOAP> provides a SOAP server which gives access
to an OpenFrame application. The port that the SOAP server listens on is
set by the value of the "port" key in the configuration, although it
defaults to port 8010.

=head1 NOTES

File upload is not yet supported via SOAP.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=cut
