package OpenFrame::Slot::XSLT;

##
## performs XSLT transforms on XML document objects
##

use strict;
use warnings::register;

use XML::LibXML;
use XML::LibXSLT;
use OpenFrame::Constants;
use OpenFrame::AbstractResponse;

sub what {
  return [ qw ( XML::LibXML::Document OpenFrame::AbstractRequest ) ];
}

sub action {
  my $class  = shift;
  my $config = shift;
  my $doc    = shift;
  my $req    = shift;

  my $ssheet;

  foreach my $mapping (@{$config->{stylesheets}}) {
    my $pattern = $mapping->{pattern};
    $ssheet     = $mapping->{stylesheet};
    if (!($pattern && $ssheet)) {
      if ($req->uri()->path() =~ /$pattern/) {
	last;
      }
    }
  }

  if (!$ssheet) {
    warnings::warn("[slot:xslt] no stylesheet mapping is valid") if $OpenFrame::DEBUG;
    return undef;
  } else {

    warnings::warn("[slot:xslt] using stylesheet $ssheet") if $OpenFrame::DEBUG;

    my $stylesheet = XML::LibXSLT->new()->parse_stylesheet( XML::LibXML->new()->parse_file( $ssheet ) );
    my $results = $stylesheet->transform( $doc );

    if (!$results) {
      warnings::warn("[slot:xslt] cannot transform document with stylesheet $ssheet") if $OpenFrame::DEBUG;
      return undef;
    } else {
      my $response = OpenFrame::AbstractResponse->new();
      $response->message( $stylesheet->output_string( $results ));
      $response->mimetype( "text/html" );
      $response->code( ofOK );
      return $response;
    }

  }
}

1;


=pod

=head1 NAME

  OpenFrame::Slot::XSLT - performs XSL transforms on XML documents

=head1 SYNOPSIS

  # see examples for slot usage

=head1 DESCRIPTION

The C<OpenFrame::Slot::XSLT> slot takes a XML::LibXML::Document object and performs
a stylesheet transform on it.  It selects the stylesheet by matching a pattern set
in the slot configuration against the URL.  If successful it places an OpenFrame::AbstractResponse
object on the slot stack.


=head1 CONFIGURATION

The slot configuration should look similar to the following:

    %
      dispatch => Local
      name => OpenFrame::Slot::XSLT
      config => %
         stylesheets => @
            %
                pattern => '/xmldocuments/',
                stylesheet => '/usr/local/stylesheets/generic.xsl'
            %
                pattern => '/some/pattern/to/match',
                stylesheet => '/some/path/to/a/stylesheet/to/use.xsl',

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 SEE ALSO

C<OpenFrame::Slot>, C<XML::LibXML>, C<XML::LibXSLT>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut


