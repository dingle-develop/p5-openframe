package OpenFrame::Slot::Misc;

use OpenFrame::Slot;
use base qw ( OpenFrame::Slot );

use OpenFrame::Constants;
use OpenFrame::Response;
use Data::Dumper;

sub what {
    return [];
}

sub action {
    my $class  = shift;
    my $config = shift;

    my $msg = $config->{ msg } || 'no message received';
    warn("misc message: $msg\n");

    return bless \$msg, 'OpenFrame::Test::Message';
}

1;
