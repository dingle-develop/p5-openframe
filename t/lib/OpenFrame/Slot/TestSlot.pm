package OpenFrame::Slot::TestSlot;

use OpenFrame::Slot;
use base qw ( OpenFrame::Slot );

use OpenFrame::Constants;
use OpenFrame::Response;

sub what {
  return [];
}

sub action {
  my $class = shift;
  my $config  = shift;

  
  if(defined( $config->{This} )&& $config->{This} eq 'Is') {
    return (OpenFrame::Response->new( code => ofERROR ),'OpenFrame::Slot::TestSlot2');
  } else {
    return OpenFrame::Response->new( code => ofERROR );
  }
}

1;
