package OpenFrame::Slot::Short;

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
    warn("short message: $msg\n");

    return OpenFrame::Response->new(
        message  => "a response in response to the message: $msg",
        mimetype => 'candy/liquorice',
        code     => ofOK );

}

1;
