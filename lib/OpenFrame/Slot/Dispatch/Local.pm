package OpenFrame::Slot::Dispatch::Local;

use strict;
use warnings::register;

sub dispatch {
  my $class    = shift;
  my $app      = shift;
  my $session  = shift;
  my $request  = shift;
  my $config   = shift;

  eval "use $app->{namespace};";
  if ($@) {
    warnings::warn("[slot::dispatch] cannot use namespace $app->{namespace} as app");
    warnings::warn($@) if (warnings::enabled() || $OpenFrame::DEBUG);	
    return undef;
  }

  my $appcode;
  if (exists $session->{application}->{ $app->{name} }) {
    my $ref  = $session->{application}->{ $app->{name} };
    if (ref($ref)) {
      $appcode = bless $ref, $app->{namespace};
    } else {
      warnings::warn("[slot::dispatch] not a reference in session") if (warnings::enabled || $OpenFrame::DEBUG);
      delete $session->{application}->{ $app->{name} };
      return undef;
    }
  } else {
    my $namespace = $app->{namespace};
    $appcode = $namespace->new();
  }

  if (Scalar::Util::blessed( $appcode )) {
    if ($appcode->can('enter')) {
      $appcode->enter($request, $session, $config);
      my %apphash = %{ $appcode };
      $session->{application}->{ $app->{name} } = \%apphash;
      return 1;
    } else {
      warnings::warn("[slot::dispatch] can't find enter method in module $app->{name}") if (warnings::enabled || $OpenFrame::DEBUG);
    }
  } else {
    warnings::warn("[slot::dispatch] could not (re)create application object") if (warnings::enabled || $OpenFrame::DEBUG);
  }

  return 1;
}

1;
