package Redirect;

use strict;
use Template;
use OpenFrame::Config;
use OpenFrame::Response;
use OpenFrame::Constants;

sub what {
  return ['OpenFrame::Request'];
}

my $html = '
<html><head><title>Redirection test</title></head>
<body>
<h1>Redirection test</h1>
<p>
Hello. This is a simple webserver which redirects any access (except the root path) back to 
the root. For example, the following URLs should redirect you straight back to this page:
<a href="/redirect/">/redirect/</a>, <a href="/test/">/test/</a>, <a href="/redirect.html">/redirect.html</a>.
</p>
</body>
</html>
';

sub action {
  my $class   = shift;
  my $config  = shift;
  my $request = shift;

  my $uri = $request->uri;
  my $response = OpenFrame::Response->new();

  if ($uri->path eq '/') {
    # Serve up the front page
    $response->message($html);
    $response->code(ofOK);
    $response->mimetype('text/html');
  } else {
    # Serve up a redirection to the front page
    $uri->path('/');
    $response->message("$uri");
    $response->code(ofREDIRECT);
    $response->mimetype('text/html');
  }
  return $response;
}

1;

__END__

=head1 NAME

Redirect - HTTP Redirection example slot for OpenFrame

=head1 DESCRIPTION

C<Redirect> is a simple example slot for OpenFrame that demonstrates
how HTTP redirection is accomplished.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
