#!/usr/bin/perl

use warnings;
use strict;
use lib '.';
use SOAP::Transport::HTTP;
use Time;

SOAP::Transport::HTTP::Daemon
  ->new(LocalPort => 8010, Reuse => 1)
  ->dispatch_to('Time')
  ->handle;
