package OpenFrame::Slot::TestSlot2;

use OpenFrame::Slot;
use base qw ( OpenFrame::Slot );

use OpenFrame::Constants;

sub what {
  return ['OpenFrame::AbstractResponse'];
}

sub action {
  my $class = shift;
  my $config  = shift;
  my $response = shift;

  if (defined $response) {
    $response->code( ofOK );
    return $response
  }
}

1;
