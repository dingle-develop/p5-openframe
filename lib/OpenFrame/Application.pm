package OpenFrame::Application;

use strict;

use Data::Dumper;
use OpenFrame::Config;

our $VERSION = 2.00;
our $epoints = {};

sub import {
  my $class = shift;
  my $args  = { @_ };
  return if !keys %{$args};
  my $pack = caller();
  {
    no strict 'refs';
    ${$pack . '::epoints'} = $args;
  }
}

sub new {
  my $class = shift;
  my $self  = {};
  bless $self, $class;
}

sub _enter {
  my $self    = shift;
  my $request = shift;
  my $session = shift;
  my $config  = shift;

  {
    no strict 'refs';

    my $epoints = $ {ref($self) . "::epoints"};

    if (ref($epoints) eq 'HASH') {
      my $enter;
      my %entry_choose;
      foreach my $entry ( keys %{ $epoints } ) {
	my $num_m = 0;
	my $params = $epoints->{$entry};
	my $num_to_match = scalar( @{$params} );
	foreach my $param (@{ $params }) {	
	  if (exists $request->arguments()->{ $param }) {
	    $num_m++;
	  }
	}
	warn("[application] examining $num_m vs $num_to_match") if $OpenFrame::DEBUG;
	if ($num_m == $num_to_match) {
	  $num_m = 0;
	  warn("[application] entering $entry") if $OpenFrame::DEBUG;
	  $session->{application}->{current}->{entrypoint} = $entry;
	  if ($self->can($entry)) {
	    return $self->$entry($session, $request, $config);
	  }
	}
      }
      warn("[application] using default entry point") if $OpenFrame::DEBUG;
      $session->{application}->{current}->{entrypoint} = 'default';
      return $self->default($session, $request, $config);
    } elsif (ref($epoints) eq 'CODE') {
      warn("[application] dispatching to subref epoint") if $OpenFrame::DEBUG;
      my $args = $request->arguments();
      my $entry = $epoints->($args) || 'default';
      warn("[application] subref epoint returned $entry") if $OpenFrame::DEBUG;
      $session->{application}->{current}->{entrypoint} = $entry;
      return $self->$entry($session, $request, $config);
    } else {
      warn("[application] using default entry point as epoints isn't hashref or subref but $epoints") if $OpenFrame::DEBUG;
      $session->{application}->{current}->{entrypoint} = 'default';
      return $self->default($session, $request, $config);
    }
  }
}

sub default {
  my $self = shift;
  my $config = OpenFrame::Config->new();
  $self->{version} = $config->getKey( 'VERSION' );
}

1;

__END__

=head1 NAME

OpenFrame::Application - Base class for all OpenFrame applications

=head1 SYNOPSIS

  package MyCompany::MyApplication;

  use OpenFrame::Application (
			      example => [
					  'param'
					 ]
			     );

  use base qw (OpenFrame::Application);

  sub default {
    my $self = shift;
    my $session = shift;
    my $request = shift;
    my $config = shift;
    $self->{message} = "no parameters for this call";
  }

  sub example {
    my $self = shift;
    my $session = shift;
    my $request = shift;
    my $config = shift;
    $self->{message} = "parameters are passed";
  }

=head1 DESCRIPTION

C<OpenFrame::Application> is the base class for all OpenFrame
applications.

To add functionality to the application, entry points are used. To
explain what we have done here, is to explain the OpenFrame
application system. Every application has a list of entry points.
Entry points define what is required to trigger certain states within
the application. The requirements are parameters passed on the command
line. For every entry point, there should be a subroutine which
defines what happens at that point.

The entry points hashref can also be passed in as an $epoints package
variable:

  our $epoints = { ... };

To enable more flexible entry points, instead of passing a hash
reference, a subroutine reference can be passed. At runtime, this
subroutine is passed the request arguments and returns the entrypoint
to be run as a string. The following code, runs the "bar" entrypoint
if there is a "foo" parameter, but note that more complicated logic
can take place here:

  our $epoints = sub {
    my $args = shift;
    if ($args->{foo}) {
      return 'bar';
    } elsif ($args->{bar}) {
      return 'quux';
    } elsif ($args->{quux}) {
      return 'foo';
    }
    return 'default';
  };

The actual entry points are passed itself, the session, an abstract
request, and per-application configuration.

Inside your templating system, after this application gets executed,
you should be able to do something like the code below, and have it
display the message in the appropriate place.

  <html>
    <head>
     <title>My First Application</title>
    </head>
    <body>
      Message is: [% application.myapp.message %]
    </body>
  </html>

You will notice that the templating system wants points to something
called 'application.myapp.message'.  The reason for this is pretty
simple.  The templating system is always provided with the users
session as parameters.  The application is stored persistantly in the
location given by the name field of the config file.  So if you point
your templating system at application.<name>.<field> it will get the
correct field of the correct application.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.



