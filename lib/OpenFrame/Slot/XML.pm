package OpenFrame::Slot::XML;

##
## returns an XML::LibXML object onto the slot stack
##

use strict;
use warnings::register;

use FileHandle;
use File::Spec;
use XML::LibXML;

use Data::Dumper;

sub what {
  return [ qw( OpenFrame::AbstractRequest ) ];
}

##
## takes a request, checks if its an XML document, then parses it
##
sub action {
  my $class   = shift;
  my $config  = shift;
  my $request = shift;

  return unless $request->uri()->as_string =~ /\.$config->{filetypes}$/;

  my $path  = $request->uri()->path();
  my $store = $config->{directory};
  
  my $fqp   = File::Spec->catfile( $store, $path );

  my $fh    = FileHandle->new( "<$fqp" );
  if ($fh) {
    my $xmlp = XML::LibXML->new();
    my $doc  = $xmlp->parse_fh( $fh );
    $fh->close();
    if ($doc) {
      return $doc;
    } else {
      warnings::warn("[slot:xml] could not parse $fqp as xml") if $OpenFrame::DEBUG;
    }
  } else {
    warnings::warn("[slot:xml] could not open $fqp to parse as xml") if $OpenFrame::DEBUG;
    return;
  }
}

1;

=pod

=head1 NAME

  OpenFrame::Slot::XML - parses XML documents

=head1 SYNOPSIS

  # see examples for slot usage

=head1 DESCRIPTION

The C<OpenFrame::Slot::XML> slot takes an OpenFrame::AbstractRequest object and
parses the file as an XML document if the file has a filetype listed in its
configuration options.  It places an XML::LibXML::Document object on the slot
stack.

=head1 CONFIGURATION

The slot configuration should look similar to the following:

    %
      dispatch => Local
      name => OpenFrame::Slot::XML
      config => %
         filetypes => '(xml|myfiletype)'
         directory => '/my/xml/directory'

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 SEE ALSO

C<OpenFrame::Slot>, C<XML::LibXML>, C<XML::LibXSLT>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut
