package OpenFrame::Slot::Dispatch::Local;

use strict;

sub dispatch {
  my $class    = shift;
  my $app      = shift;
  my $session  = shift;
  my $request  = shift;
  my $config   = shift;

  eval "use $app->{namespace};";
  if ($@) {
    warn("[slot::dispatch] cannot use namespace $app->{namespace} as app") if $OpenFrame::DEBUG;
    warn($@) if $OpenFrame::DEBUG;	
    return undef;
  }

  my $appcode;
  if (exists $session->{application}->{ $app->{name} }) {
    my $ref  = $session->{application}->{ $app->{name} };
    if (ref($ref)) {
      $appcode = bless $ref, $app->{namespace};
    } else {
      warn("[slot::dispatch] not a reference in session") if $OpenFrame::DEBUG;
      delete $session->{application}->{ $app->{name} };
      return undef;
    }
  } else {
    my $namespace = $app->{namespace};
    $appcode = $namespace->new();
  }

  if (Scalar::Util::blessed( $appcode )) {
    if ($appcode->can('_enter')) {
      $appcode->_enter($request, $session, $config);
      my %apphash = %{ $appcode };
      $session->{application}->{ $app->{name} } = \%apphash;
      return 1;
    } else {
      warn("[slot::dispatch] can't find enter method in module $app->{name}") if $OpenFrame::DEBUG;
    }
  } else {
    warn("[slot::dispatch] could not (re)create application object") if $OpenFrame::DEBUG;
  }

  return 1;
}

1;
