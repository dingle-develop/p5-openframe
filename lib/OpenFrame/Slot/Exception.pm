package OpenFrame::Slot::Exception;

use strict;
use OpenFrame::Exception;


sub what {
  return ['OpenFrame::SlotStore'];
}

sub action {
  my $self = shift;
  my $conf = shift;
  my $vars = shift;

  my $req  = $vars->lookup( 'OpenFrame::AbstractRequest' );
  my $excp = $vars->lookup( 'OpenFrame::Exception::Perl' );

  my $type = ref($excp) || $excp;
  my $uri  = $req->uri()->as_string();

  my $bgn  = qq{[exception]};

  if ($excp->{message} =~ /Can\'t locate (.+?)\s/) {
    my $module = $1;
    if ($module =~ /slot/i) {
      $module =~ s/\//\:\:/g;
      $module = substr($module, 0, rindex($module, '.'));
      warn("$bgn caught $type: slot $module not found");
    } else {
      warn("$bgn failed to load module: $module");
    }
  } else {
    warn("$bgn caught $type exception while handling request for $uri\n$excp->{message}");
  }

  $excp = $vars->lookup( 'OpenFrame::Exception::Slot' );
  warn("$bgn $excp->{message}");

}

1;

=head1 NAME

OpenFrame::Slot::Exception - demonstration slot

=head1 DESCRIPTION

C<OpenFrame::Slot::Exception> is provided to demonstrate use of the OpenFrame::SlotStore request.  It looks
various exceptions in the slot stack to see what has been thrown, and reports them via warn statements.
Specifically it looks at Slot exceptions (thrown when a slot cannot be executed due to lack of required
parameters) and reports that particular anomaly.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=cut

