package OpenFrame::Slot::Dispatch;

our $VERSION = 1.00;

use strict;
use warnings::register;

use OpenFrame::Slot;
use OpenFrame::Config;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;

use Data::Denter;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::Session', 'OpenFrame::AbstractRequest'];
}

sub action {
  my $class   = shift;
  my $session = shift;
  my $request = shift;

  my $config  = OpenFrame::Config->new();
  my $applist = $config->getKey( 'installed_applications' );

  if (!ref($applist)) {
    warnings::warn("[slot::dispatch] installed_applications not a list") if (warnings::enabled || $OpenFrame::DEBUG);
    return undef;
  }

  warnings::warn("[slot::dispatch] path to match is ".$request->getURI()->path()) if (warnings::enabled || $OpenFrame::DEBUG);

  foreach my $app (@$applist) {
    warnings::warn("[slot::dispatch]\ttesting against $app->{name} ($app->{uri})") if (warnings::enabled || $OpenFrame::DEBUG);
    if ($request->getURI()->path() =~ /$app->{uri}/) {
      warnings::warn("[slot::dispatch]\tmatched. app is $app->{name}") if (warnings::enabled || $OpenFrame::DEBUG);

      my $dispatch = $app->{dispatch};
      my $fqpn     = $class . "::" . $dispatch;
      my $loaded   = 0;

      eval "use $fqpn";
      if (!$@) {
	$loaded = 1;
      }

      if ($loaded) {
	unless ( $fqpn->dispatch( $app, $session, $request ) ) {
	  warnings::warn("[slot::dispatch] dispatch type $dispatch returned error") if (warnings::enabled || $OpenFrame::DEBUG);
	  return undef;
	} else {
	  return 1;
	}
      } else {
	warnings::warn("[slot::dispatch] cannot dispatch via $app->{dispatch}") if (warnings::enabled || $OpenFrame::DEBUG);
	return undef;
      }
    } else {
      warnings::warn("[slot::dispatch] $app->{uri} did not match " . $request->getURI()->path()) if (warnings::enabled || $OpenFrame::DEBUG);
    }
  }
  
}

1;

