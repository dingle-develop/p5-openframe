package OpenFrame::Slot::Cleaner;

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
    warn("cleaner message: $msg\n");

    return bless \$msg, 'OpenFrame::Test::Message';
}

1;
