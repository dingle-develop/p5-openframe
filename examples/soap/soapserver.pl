#!/usr/bin/perl -w
#
# The hangman images are by Andy Wardley
#
# This version of hangman uses templates and SOAP

use strict;
use lib '../hangman2';
use lib '../../lib';

use OpenFrame::Config;
use OpenFrame::Server::SOAP;

my $config = OpenFrame::Config->new();
$config->setKey(
                'SLOTS',
                [
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Images',
		  config   => { directory => '../hangman/' },
                 },
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
							   namespace => 'hangman',
							   uri       => '/',
							   dispatch  => 'Local',
							   name      => 'Hangman::Application',
							   config    => { words => "../hangman/words.txt" },
							  },
							 ],
			      },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'Hangman::Generator',
		  config   => { presentation => '../hangman2/templates/' },
                 },
                ]
               );
$config->setKey(DEBUG => 0);

my $h = OpenFrame::Server::SOAP->new(port => 8010);
print "SOAP access to hangman is available at http://localhost:8010/ !\n";
$h->handle();

__END__

=head1 NAME

soapserver.pl - A simple SOAP hangman example for OpenFrame

=head1 DESCRIPTION

This Perl script contains a small and understandable SOAP application
for OpenFrame that allows you to play Hangman (via SOAP). Run
soapclient.pl to see it work.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

