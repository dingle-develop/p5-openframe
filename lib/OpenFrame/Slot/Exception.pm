package OpenFrame::Slot::Exception;

use strict;
use warnings::register;
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
      warnings::warn("$bgn caught $type: slot $module not found");
    } else {
      warnings::warn("$bgn failed to load module: $module");
    }
  } else {
    warnings::warn("$bgn caught $type exception while handling request for $uri\n$excp->{message}");
  }

  $excp = $vars->lookup( 'OpenFrame::Exception::Slot' );
  warnings::warn("$bgn $excp->{message}");

}

1;

