#!/usr/bin/perl -w
#
# A simple version of Eliza

use strict;
use lib '../../lib';

use OpenFrame;
use OpenFrame::Server::HTTP;

my $config = OpenFrame::Config->new();
$config->setKey(
                'SLOTS',
                [
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Session',
		  config   => {
			       default_session => {
						   language => 'en',
						   country  => 'UK',
						   application => {},
						  },
			       },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Dispatch',
		  config   => {
			       installed_applications => [
							  {
							   namespace => 'eliza',
							   uri       => '/',
							   dispatch  => 'Local',
							   name      => 'Eliza::Application',
							  },
							 ],
			      },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'Eliza::Generator',
		  config   => { presentation => 'templates/' },
                 },
                ]
               );
$config->setKey(DEBUG => 0);

my $h = OpenFrame::Server::HTTP->new(port => 8000);
print "Point your browser to http://localhost:8000/ to talk to Eliza!\n";
$h->handle();

__END__

=head1 NAME

hangman.pl - A simple web hangman templated example for OpenFrame

=head1 DESCRIPTION

This Perl script contains a small and understandable web application
for OpenFrame that allows you to play Hangman with your web browser.

This uses an C<OpenFrame::Server::HTTP> stand-alone HTTP server, and
sets up an C<OpenFrame::Config> object with various slots: one for
static images, one for session support, a simple dispatch slot, and
another slot which generates output using the Template Toolkit.

Run the script and point your favourite web browser at
http://localhost:8000/

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

