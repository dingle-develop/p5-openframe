package OpenFrame::Constants;

use strict;

use Exporter;
use base qw ( Exporter );

our @EXPORT = qw( ofOK ofDECLINED ofREDIRECT ofERROR );
our @DEBUG  = qw( ofDEBUG_VERBOSE ofDEBUG_CONFIG ofDEBUG_STORE 
		  ofDEBUG_SLOT ofDEBUG_SESSION ofDEBUG_APPLICATION 
		  ofDEBUG_GENERATOR ofDEBUG_DISPATCH ofDEBUG_IMAGES 
		  ofDEBUG_SLOTS ofDEBUG_ALL );
 
our @EXPORT_OK   = ( @EXPORT, @DEBUG );
our %EXPORT_TAGS = (
    'all'        => [ @EXPORT_OK ],
    'debug'      => [ @DEBUG     ],
);


##
## constants for messages in OpenFrame
##
use constant ofOK       => 1;
use constant ofDECLINED => 2;
use constant ofREDIRECT => 3;
use constant ofERROR    => 4;

##
## debug constants
##
use constant ofDEBUG_VERBOSE     =>    1;
use constant ofDEBUG_CONFIG      =>    2;
use constant ofDEBUG_STORE       =>    4;
use constant ofDEBUG_SLOT        =>    8;
use constant ofDEBUG_SESSION     =>   16;
use constant ofDEBUG_APPLICATION =>   32;
use constant ofDEBUG_GENERATOR   =>   64;
use constant ofDEBUG_DISPATCH    =>  128;
use constant ofDEBUG_IMAGES      =>  256;
use constant ofDEBUG_SLOTS       =>  512;

use constant ofDEBUG_ALL         => 1023;


1;

__END__

=head1 NAME

OpenFrame::Constants - Constants for OpenFrame

=head1 SYNOPSIS

  use OpenFrame::Response;
  use OpenFrame::Constants;

  my $response = OpenFrame::Response->new();
  $response->message($output);
  $response->code(ofOK);
  $response->mimetype('text/html');
  $response->cookies($cookie);

=head1 DESCRIPTION

C<OpenFrame::Constants> exports some constants which are of general
use inside OpenFrame.

=head1 CONSTANTS

=head2 OpenFrame::Response constants

The following constants are valid as codes of an
C<OpenFrame::Response> object:

=over 4

=item ofOK

The response is okay.

=item ofERROR

The response is an error.

=item ofREDIRECT

The response is a redirect.

=item ofDECLINED

The response was declined.

=back

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

