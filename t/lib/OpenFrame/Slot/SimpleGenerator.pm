package OpenFrame::Slot::SimpleGenerator;

use strict;
use Data::Dumper;
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

  my $sessioncopy;
  eval Data::Dumper->Dump([$session], ["sessioncopy"]);

  $response->message($sessioncopy);
  $response->code(ofOK);
  $response->mimetype('openframe/session');
  $response->cookies($cookietin);

  return $response;
}

1;



