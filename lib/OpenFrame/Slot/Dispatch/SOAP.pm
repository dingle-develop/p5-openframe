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
    my $uri   = $app->{soap_uri} . $app->{name} . '/';
    my $proxy = $app->{soap_proxy};

    $soapslot = new SOAP::Lite->uri( $uri )->proxy( $proxy );

  } elsif ($app->{service}) {
    my $service = $app->{service};
    $soapslot = SOAP::Lite->service( $service );
  }

  my $appcode;
  if (exists $session->{application}->{ $app->{namespace} }) {
    my $ref  = $session->{application}->{ $app->{namespace} };
    if (ref($ref)) {
      $appcode = bless $ref, $app->{name};
    } else {
      warn("[slot::dispatch] not a reference in session") if $OpenFrame::DEBUG;
      delete $session->{application}->{ $app->{namespace} };
      return undef;
    }
  } else {
    my $name = $app->{name};
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
    $session->{application}->{$app->{namespace}} = \%apphash;
    return $result;
  }

  return 1;
}

1;

__END__

=head1 NAME

OpenFrame::Slot::Dispatch::SOAP - Dispatch applications remotely via SOAP

=head1 SYNOPSIS

  my $config = OpenFrame::Config->new();
  $config->setKey(
     'SLOTS', [ {
       dispatch => 'Local',
       namespace => 'OpenFrame::Slot::Dispatch',
       config   => {
         installed_applications => [ {
           namespace => 'hangman',
           uri        => '/',
           dispatch   => 'SOAP',
           namespace  => 'Hangman::Application',
           config     => { words => "../hangman/words.txt" },
           soap_uri   => 'http://localhost:8010/',
           soap_proxy => 'http://localhost:8010/',
         },],
       },
     },
   ],
  );

=head1 DESCRIPTION

This module is an OpenFrame slot that dispatches applications that use
OpenFrame::Slot::Dispatch remotely via SOAP.

There are two ways of defining the SOAP endpoint, either use the
"soap_uri" and "soap_proxy" options or use a "service" options to
point to a WSDL location.

=head1 SEE ALSO

OpenFrame::Slot::Dispatch

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

