package OpenFrame::Slot::Dispatch::SOAP;

use strict;

sub dispatch {
  my $class    = shift;
  my $app      = shift;
  my $session  = shift;
  my $request  = shift;
  my $config   = shift;

  my $soapslot;
  if ($app->{soap_proxy} && $app->{soap_uri}) {
    my $uri   = $app->{soap_uri} . $app->{namespace} . '/';
    my $proxy = $app->{soap_proxy};

    $soapslot = new SOAP::Lite->uri( $uri )->proxy( $proxy );

  } elsif ($app->{service}) {
    my $service = $app->{service};
    $soapslot = SOAP::Lite->service( $service );
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
    my $result = $soapslot->call('new');
    if ($result->fault()) {
      my $excp = OpenFrame::Exception::Perl->new($result->faultstring());
      $excp->throw();
      return;
    } else {
      $appcode = $result->result;
    }
  }

  my $result = $soapslot->call('enter', $appcode, $request, $session, $config);
  if ($result->fault()) {
    my $excp = OpenFrame::Exception::Perl->new($result->faultstring());
    $excp->throw();
    return;
  } else {
    my %apphash = %$appcode;
    $session->{application}->{$app->{name}} = \%apphash;
    return 1;
  }

  return 1;
}

1;
