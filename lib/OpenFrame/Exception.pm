package OpenFrame::Exception;

use strict;

our @stack;

sub new {
  my $class    = shift;
  my $self     = {
		  message => shift,
		 };
  bless $self, $class;
}

sub message {
  my $self = shift;
  $self->{message} = $_[0] || return $_[0];
}

sub throw {
  my $this = shift;
  my $type = ref($this);

  warn("[exception] exception of type $type thrown: $this->{message}") if $OpenFrame::DEBUG;

  push @OpenFrame::Exception::stack, $this;
}

package OpenFrame::Exception::Perl;

use base qw ( OpenFrame::Exception );

package OpenFrame::Exception::Application;

use base qw ( OpenFrame::Exception );

package OpenFrame::Exception::Slot;

use base qw ( OpenFrame::Exception );

1;

__END__

=head1 NAME

OpenFrame::Exception - Provides exception handling for OpenFrame

=head1 SYNOPSIS

  use OpenFrame::Exception;

  my $excp = OpenFrame::Exception::Type->new( $message );
  $excp->throw();

=head1 DESCRIPTION

As Perl does not have an exception mechanism of its own beyond $@, and
as $@ is used frequently by OpenFrame, yet another exception mechanism
is desirable within OpenFrame.  There are three defined exception
classes in OpenFrame: I<OpenFrame::Exception::Perl>,
I<OpenFrame::Exception::Application>, and
I<OpenFrame::Exception::Slot>.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 BUGS

You can only write a slot to deal with one of any given exception classes.

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
