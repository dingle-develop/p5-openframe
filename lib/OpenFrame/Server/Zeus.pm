package OpenFrame::Server::Zeus;
use strict;
use CGI::Fast;
use OpenFrame::Config;
use OpenFrame::Constants;
use OpenFrame::Server;
use OpenFrame::Server::Direct;

our $VERSION = 2.12;

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  return $self;
}

sub handle {
  my $self = shift;

  while (my $q = CGI::Fast->new()) {
    my $url = "http://localhost" . $q->path_info . "?" . $q->query_string;

    my $cookietin = OpenFrame::Cookietin->new();
    $cookietin->set("session", $q->cookie("session"));

    my $direct = OpenFrame::Server::Direct->new();
    my $response;
    ($response, $cookietin) = $direct->handle($url, $cookietin);

    if ($response->code() == ofOK) {
      my $cookie = $q->cookie(-name=>'session',
			      -value=>$cookietin->get('session'));
      print $q->header(-type=>$response->mimetype, -cookie=>$cookie);
      #  print $url;
      print $response->message();
    } else {
      print $q->header;
      print "Some sort of error. Drat.";
    }
  }
}

1;

__END__

=head1 NAME

OpenFrame::Server::Zeus - Zeus extension for OpenFrame

=head1 SYNOPSIS

  my $zeus = OpenFrame::Server::Zeus->new();
  $zeus->handle();

=head1 DESCRIPTION

C<OpenFrame::Server::Zeus> HTTP access to an OpenFrame application via
the Zeus web server.

Configuring this is somewhat tricky: have a look at the zeus
example. First, create a zeus.fcgi directory in your Zeus web server
document root. It should be similar to the one in the zeus example:
set up an C<OpenFrame::Config> option and then call
C<OpenFrame::Server::Zeus>.

The Zeus webserver must be configured: create a new virtual server (or
modify an existing one). Set the web server document root to be the
document root, and enable FCGI (along with "Enable FastCGI programs to
be located anywhere"). Now set up a handler to map all required
requests (such as "html") to "/zeus.cgi". Apply and commit the
changes, and restart the webserver. That should be it.

Note that performance of applications run under this module is fair,
but C<OpenFrame::Server::Apache> and C<OpenFrame::Server:HTTP> are
somewhat faster.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=cut
