package OpenFrame::Server;

use strict;
use warnings::register;

use OpenFrame::Slot;
use OpenFrame::Config;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;

sub action {
  my $class = shift;
  my $req   = shift;

  my $return_via = caller();

  my $response;

  my $config   = OpenFrame::Config->new();

  $OpenFrame::DEBUG = $config->getKey( 'DEBUG' );

  my $SLOTS    = $config->getKey( 'SLOTS' );
  if ($SLOTS && ref( $SLOTS ) eq 'ARRAY') {
    $response = OpenFrame::Slot->action( $req, $SLOTS );
  }

  my $POST = $config->getKey( 'POSTSLOTS' );
  if ($POST && ref( $POST ) eq 'ARRAY') {
    OpenFrame::Slot->action( $req,  $POST );
  }

  return $response;
}

1;




