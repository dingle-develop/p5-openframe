package Hangman::Generator;

use strict;
use OpenFrame::AbstractResponse;
use OpenFrame::Config;
use OpenFrame::Constants;

sub what {
  return ['OpenFrame::Session', 'OpenFrame::AbstractRequest', 'OpenFrame::AbstractCookie'];
}

sub action {
  my $class   = shift;
  my $config  = shift;
  my $session = shift;
  my $request = shift;
  my $cookietin  = shift;

  my $name = $session->{application}->{current}->{name};
  my $output = $session->{application}->{$name}->{message};

  return unless $request->uri()->path eq "/";

  my $response = OpenFrame::AbstractResponse->new();
  $response->message($output);
  $response->code(ofOK);
  $response->mimetype('text/html');
  $response->cookies($cookietin);

  return $response;
}

1;

__END__

=head1 NAME

Hangman::Generator - A trivial output generator for hangman

=head1 DESCRIPTION

C<Hangman::Generator> is a trivial output generator for hangman. The
message to be output is passed inside the session, and the code then
generates a response.

Note that it explicity checks if the request is meant for the
application, rather than an image, by checking for "/".

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.



