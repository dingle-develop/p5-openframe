#!/usr/bin/perl -w
#
# A simple redirection example

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
                  name     => 'Redirect',
		  },
                ],
               );
$config->setKey(DEBUG => 0);

my $h = OpenFrame::Server::HTTP->new(port => 8000);
print "Point your browser to http://localhost:8000/ to see redirection!\n";
$h->handle();

__END__

=head1 NAME

redirect.pl - A simple HTTP redirection example for OpenFrame

=head1 DESCRIPTION

This Perl script contains a small web application that demonstrates HTTP redirection.

Run the script and point your favourite web browser at
http://localhost:8000/

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2002, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

