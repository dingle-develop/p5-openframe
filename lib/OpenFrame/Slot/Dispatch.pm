package OpenFrame::Slot::Dispatch;

our $VERSION = 2.12;

use strict;

use OpenFrame::Slot;
use OpenFrame::Config;
use OpenFrame::Request;
use OpenFrame::Response;
use OpenFrame::Constants qw( :debug );
use Data::Denter;

use base qw ( OpenFrame::Slot );

our $DEBUG  = ($OpenFrame::DEBUG || 0) & ofDEBUG_DISPATCH;
*warn = \&OpenFrame::warn;

sub what {
    return ['OpenFrame::Session', 'OpenFrame::Request'];
}

sub action {
  my $class   = shift;
  my $config  = shift;
  my $session = shift;
  my $request = shift;

  my $applist = $config->{installed_applications};

  $DEBUG = ($OpenFrame::DEBUG || 0) & ofDEBUG_DISPATCH;

  if (!ref($applist)) {
    &warn("installed_applications not a list") if $DEBUG;
    return undef;
  }

  my $path = $request->uri()->path();

  &warn("path to match is $path") if $DEBUG;

  foreach my $app (@$applist) {
    &warn("testing path [$path] against [$app->{uri}]") if $DEBUG;
    if ($path =~ /$app->{uri}/) {
      &warn("matched. app is $app->{namespace}") if $DEBUG;
      $session->{application}->{current}->{namespace} = $app->{namespace};
      $session->{application}->{current}->{name} = $app->{name};
      $session->{application}->{current}->{dispatch} = $app->{dispatch};

      my $dispatch = $app->{dispatch};
      my $fqpn     = $class . "::" . $dispatch;
      my $loaded   = 0;

      eval "use $fqpn";
      if ($@) {
	&warn("error loading $fqpn: $@");
      } else {
	$loaded = 1;
      }

      if ($loaded) {
	my $response = $fqpn->dispatch( $app, $session, $request, $app->{config} );
	unless ( $response ) {
	  &warn("dispatch type $dispatch returned error") if $DEBUG;
	  return undef;
	} else {
	  return $response;
	}
      } else {
	&warn("cannot dispatch via $app->{dispatch}") if $DEBUG;
	return undef;
      }
    } else {
      &warn("$app->{uri} did not match $path") if $DEBUG;
    }
  }

  return 1;
}

1;

__END__

=head1 NAMESPACE

OpenFrame::Slot::Dispatch - Dispatch applications

=head1 SYNOPSIS

  my $config = OpenFrame::Config->new();
  $config->setKey(
     'SLOTS', [ {
       dispatch => 'Local',
       namespace     => 'OpenFrame::Slot::Dispatch',
       config   => {
         installed_applications => [
           {
             namespace      => 'hangman',
             uri       => '/hangman/',
             dispatch  => 'Local',
             name => 'Hangman::Application',
             config   => { words => "../hangman/words.txt" },
           },
           {
             namespace      => 'eliza',
             uri       => '/eliza/',
             dispatch  => 'Local',
             name => 'Eliza::Application',
           },
         ],
       },
     },
   ],
  );

=head1 DESCRIPTION

This module is a special OpenFrame slot that allows dispatching of
applications depending on the URI. It is useful for as functionality
is often distributed via different URIs.

It is important to remember that C<OpenFrame::Slot::Dispatch> requires
a session to work, so you must have included an
C<OpenFrame::Slot::Session> previously in the slot pipeline before
this is run.

Each application is tested in turn with the current
C<OpenFrame::Request>, and if the request URI matches the
application URI the application is dispatched.

Each application has its own namespace, determined via the "namespace"
option. This allows each application to save data inside the session.

The Perl module to be loaded and run when the application is
dispatched is set via the "name" option. See
C<OpenFrame::Application> for what this module should contain.

Each application can also optionally have a "config" option, which is
passed to the application when it is dispatched.

Applications can either be local ("dispatch" => "Local") or remote via
SOAP ("dispatch" => "SOAP").

=head1 SEE ALSO

OpenFrame::Application, OpenFrame::Slot::Dispatch::Local,
OpenFrame::Slot::Dispatch::SOAP

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.


