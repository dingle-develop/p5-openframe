package OpenFrame::Object;

use strict;
use warnings::register;

use OpenFrame;

our $VERSION = '3.00';

sub new {
  my $class = shift;
  my $self  = {};
  bless $self, $class;
  $self->init();
  return $self;
}

sub init {
  my $self = shift;
}

sub error {
  my $self = shift;
  my $mesg = shift;
  my $pack = ref( $self );
  my ($package, $filename, $line, $subroutine, $hasargs,
      $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller( 1 );
  if ($OpenFrame::DEBUG{ ALL } || $OpenFrame::DEBUG{ $pack }) {
    warnings::warn("[$pack\::$subroutine] $mesg");
  }
}

1;

