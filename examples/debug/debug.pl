#!/usr/bin/perl -w
#
# The hangman images are by Andy Wardley
#
# This version of hangman uses templates

use strict;
use lib '../hangman2';
use lib '../../lib';

use OpenFrame::Config;
use OpenFrame::Server::HTTP;
use Template;
use Template::Stash;

# Hack in a new listop until a new version of TT2 is out
$Template::Stash::LIST_OPS->{hashref} =
  sub {
    my $list = shift;
    my %hash = @$list;
    return \%hash;
};


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
                  name => 'Hangman::Generator',
		  config   => { presentation => 'templates/' },
                 },
                ]
               );
$config->setKey(DEBUG => 0);

my $h = OpenFrame::Server::HTTP->new(port => 8000);
print "Point your browser to http://localhost:8000/ to debug!\n";
$h->handle();

__END__

=head1 NAME

debug.pl - A simple OpenFrame debugger

=head1 DESCRIPTION

This Perl script contains a simple OpenFrame debugger. This can
present all the requests, responses, and sessions recorded during
use of C<OpenFrame::Slot::Debugger>.

Run the script and point your favourite web browser at
http://localhost:8000/

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

