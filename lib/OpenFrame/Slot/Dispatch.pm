package OpenFrame::Slot::Dispatch;

our $VERSION = 1.00;

use strict;

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
  my $config  = shift;
  my $session = shift;
  my $request = shift;

  my $applist = $config->{installed_applications};

  if (!ref($applist)) {
    warn("[slot::dispatch] installed_applications not a list") if $OpenFrame::DEBUG;
    return undef;
  }

  warn("[slot::dispatch] path to match is ".$request->uri()->path()) if $OpenFrame::DEBUG;

  foreach my $app (@$applist) {
    warn("[slot::dispatch]\ttesting against $app->{name} ($app->{uri})") if $OpenFrame::DEBUG;
    if ($request->uri()->path() =~ /$app->{uri}/) {
      warn("[slot::dispatch]\tmatched. app is $app->{name}") if $OpenFrame::DEBUG;
      $session->{application}->{current}->{name} = $app->{name};
      $session->{application}->{current}->{namespace} = $app->{namespace};
      $session->{application}->{current}->{dispatch} = $app->{dispatch};

      my $dispatch = $app->{dispatch};
      my $fqpn     = $class . "::" . $dispatch;
      my $loaded   = 0;

      eval "use $fqpn";
      if ($@) {
	warn("[slot::dispatch] error loading $fqpn: $@") if $OpenFrame::DEBUG;
      } else {
	$loaded = 1;
      }

      if ($loaded) {
	unless ( $fqpn->dispatch( $app, $session, $request, $app->{config} ) ) {
	  warn("[slot::dispatch] dispatch type $dispatch returned error") if $OpenFrame::DEBUG;
	  return undef;
	} else {
	  return 1;
	}
      } else {
	warn("[slot::dispatch] cannot dispatch via $app->{dispatch}") if $OpenFrame::DEBUG;
	return undef;
      }
    } else {
      warn("[slot::dispatch] $app->{uri} did not match " . $request->uri()->path()) if $OpenFrame::DEBUG;
    }
  }
  
}

1;

