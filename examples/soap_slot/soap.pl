#!/usr/bin/perl -w

use strict;
use lib '../../lib';

use OpenFrame::Config;
use OpenFrame::Server::HTTP;

my $config = OpenFrame::Config->new();
$config->setKey(
		'SLOTS',
	        [
		 {
		  dispatch   => 'SOAP',
		  name       => 'Time',
		  soap_uri   => 'http://localhost:8010/',
		  soap_proxy => 'http://localhost:8010/',
		 },
		]
	       );

$config->setKey(DEBUG => 0);

my $h = OpenFrame::Server::HTTP->new(port => 8000);
print "Point your browser to http://localhost:8000/ to see the current time!\n";
$h->handle();

__END__

=head1 NAME

webserver.pl - A simple web server example for OpenFrame

=head1 DESCRIPTION

This Perl script is a example web server and a small and clear
example of an OpenFrame application.

This uses an C<OpenFrame::Server::HTTP> stand-alone HTTP server, and
sets up an C<OpenFrame::Config> object with two slots: one for static
HTML files and one for static images. Note that the slots can take
configuration options.

Run the script and point your favourite web browser at
http://localhost:8000/

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.


