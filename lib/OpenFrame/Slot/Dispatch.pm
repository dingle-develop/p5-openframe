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

  my $path = $request->uri()->path();

  warn("[slot::dispatch] path to match is $path") if $OpenFrame::DEBUG;

  foreach my $app (@$applist) {
    warn("[slot::dispatch]\ttesting against $app->{name} ($app->{uri})") if $OpenFrame::DEBUG;
    if ($path =~ /$app->{uri}/) {
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
	my $response = $fqpn->dispatch( $app, $session, $request, $app->{config} );

	unless ( $response ) {
	  warn("[slot::dispatch] dispatch type $dispatch returned error") if $OpenFrame::DEBUG;
	  return undef;
	} else {
	  return $response;
	}
      } else {
	warn("[slot::dispatch] cannot dispatch via $app->{dispatch}") if $OpenFrame::DEBUG;
	return undef;
      }
    } else {
      warn("[slot::dispatch] $app->{uri} did not match $path") if $OpenFrame::DEBUG;
    }
  }
}

1;

__END__

=head1 NAME

OpenFrame::Slot::Dispatch - Dispatch applications

=head1 SYNOPSIS

  my $config = OpenFrame::Config->new();
  $config->setKey(
     'SLOTS', [ {
       dispatch => 'Local',
       name     => 'OpenFrame::Slot::Dispatch',
       config   => {
         installed_applications => [
           {
             name      => 'hangman',
             uri       => '/hangman/',
             dispatch  => 'Local',
             namespace => 'Hangman::Application',
             config   => { words => "../hangman/words.txt" },
           },
           {
             name      => 'eliza',
             uri       => '/eliza/',
             dispatch  => 'Local',
             namespace => 'Eliza::Application',
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
C<OpenFrame::AbstractRequest>, and if the request URI matches the
application URI the application is dispatched.

Each application has its own name, determined via the "name"
option. This allows each application to save data inside the session.

The Perl module to be loaded and run when the application is
dispatched is set via the "namespace" option. See
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

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.


