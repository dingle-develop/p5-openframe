package OpenFrame::Server::Direct;

use strict;
use CGI;
use OpenFrame::Server;
use OpenFrame::AbstractCookie;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;
use Scalar::Util qw(blessed);
use URI;

our $VERSION = '1.01';

sub new {
  my $class = shift;
  my $config = shift;

  my $self = {};
  $self->{_config} = $config || OpenFrame::Config->new();

  bless $self, $class;

  return $self;
}

sub handle {
  my $self = shift;
  my $url = shift;
  my $cookietin = shift || OpenFrame::AbstractCookie->new();

  # abstract the request
  my $uri = URI->new($url);
  my $cgi = CGI->new($uri->query);
  my $args = { map { ($_, $cgi->param($_)) } $cgi->param() };
  $uri->query(undef);

  my $abstractRequest = OpenFrame::AbstractRequest->new(
							uri         => $uri,
							descriptive => 'web',
							arguments   => $args,
							cookies     => $cookietin,
						       );

  my $response = OpenFrame::Server->action($abstractRequest, $self->{_config});
  return wantarray() ? ($response, $response->cookies()) : $response;

}

1;

__END__

=head1 NAME

OpenFrame::Server::Direct - Provide direct access to OpenFrame

=head1 SYNOPSIS

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

C<OpenFrame::Server::Direct> provides direct access to an OpenFrame
application (without having to set up Apache). It takes a URL as input
and returns the C<OpenFrame::AbstractResponse> object resulting from
processing that URL. Note that you have to create a cookietin at the
beginning, and keep on getting it back and passing it in in order for
cookies to work.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut
