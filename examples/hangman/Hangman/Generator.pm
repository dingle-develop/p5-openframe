package Hangman::Generator;

use strict;
use warnings::register;

use OpenFrame::Config;
use OpenFrame::AbstractResponse;
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



