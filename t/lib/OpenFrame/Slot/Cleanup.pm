package OpenFrame::Slot::Cleanup;

use OpenFrame::Slot;
use base qw ( OpenFrame::Slot );

use OpenFrame::Constants;
use OpenFrame::Response;

sub what {
    return [];
}

sub action {
    my $class  = shift;
    my $config = shift;

    my $msg = $config->{ msg } || 'no message received';
    warn("cleanup message: $msg\n");
    $config->{ msg } .= ' (modified by cleanup initiator)';
    return 'OpenFrame::Slot::Cleaner';
}

1;
