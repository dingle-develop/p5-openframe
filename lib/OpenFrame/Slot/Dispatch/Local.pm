package OpenFrame::Slot::Dispatch::Local;

use strict;

sub dispatch {
  my $class    = shift;
  my $app      = shift;
  my $session  = shift;
  my $request  = shift;
  my $config   = shift;

  eval "use $app->{name};";
  if ($@) {
    warn("[slot::dispatch] cannot use name $app->{name} as app") if $OpenFrame::DEBUG;
    warn($@) if $OpenFrame::DEBUG;	
    return undef;
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
    $appcode = $name->new();
  }

  if (Scalar::Util::blessed( $appcode )) {
    if ($appcode->can('_enter')) {
      my $code = $appcode->_enter($request, $session, $config);
      my %apphash = %{ $appcode };
      $session->{application}->{ $app->{namespace} } = \%apphash;
      return $code;
    } else {
      warn("[slot::dispatch] can't find enter method in module $app->{name}") if $OpenFrame::DEBUG;
    }
  } else {
    warn("[slot::dispatch] could not (re)create application object") if $OpenFrame::DEBUG;
  }

  return 1;
}

1;

__END__

=head1 NAME

OpenFrame::Slot::Dispatch::Local - Dispatch applications locally

=head1 SYNOPSIS

  my $config = OpenFrame::Config->new();
  $config->setKey(
     'SLOTS', [ {
       dispatch => 'Local',
       namespace => 'OpenFrame::Slot::Dispatch',
       config   => {
         installed_applications => [ {
           namespace => 'hangman',
           uri       => '/',
           dispatch  => 'Local',
           namespace => 'Hangman::Application',
           config   => { words => "../hangman/words.txt" },
         },],
       },
     },
   ],
  );

=head1 DESCRIPTION

This module is an OpenFrame slot that dispatches applications that use
OpenFrame::Slot::Dispatch locally.

=head1 SEE ALSO

OpenFrame::Slot::Dispatch

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

