package OpenFrame::Slot::SimpleGenerator;

use strict;
use warnings::register;

use Template;
use OpenFrame::Config;
use OpenFrame::AbstractResponse;
use OpenFrame::Constants;

sub what {
  return ['OpenFrame::Session', 'OpenFrame::AbstractRequest', 'OpenFrame::AbstractCookie'];
}

sub action {
  my $class     = shift;
  my $config    = shift;
  my $session   = shift;
  my $request   = shift;
  my $cookietin = shift;

  my $output;

  my $response = OpenFrame::AbstractResponse->new();
  $response->message($session);
  $response->code(ofOK);
  $response->mimetype('openframe/session');
  $response->cookies($cookietin);

  return $response;
}

1;



