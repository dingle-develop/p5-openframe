package OpenFrame::Config;

use strict;

use FileHandle;
use Scalar::Util;
use Data::Denter;
use Fcntl qw ( :flock );

our $VERSION = '1.00';

## where to look and order in which to look for config files
my $CONFIGFILES = [qw( ./.openframe.conf /etc/openframe.conf )];
my $CONFIG      = {};

=head1 NAME

OpenFrame::Config - Simple OpenFrame configuration

=head1 SYNOPSIS

  use OpenFrame;
  my $config = OpenFrame::Config->new();
  my $value = $config->getKey('fred');
  $config->setKey('rainy', 'yes');

=head1 DESCRIPTION

This module is a simple configuration interview for OpenFrame. All
OpenFrame configuration will use this module.

There are two main methods of configuring OpenFrame: use Perl to
create the configuration file using this module or edit an existing
configuration file by hand.

Editing an existing file by hand is fairly painless due to the fact
that configuration files are output using Data::Denter, which is a
Perl data serializer that is optimized for human
readability/editability, safe deserialization, and (eventually) speed.

The rest of this document will assume that you are intending to create
the configuration file using Perl.

There are two special locations that C<OpenFrame::Config> will look to
read a configuration file if you do not supply the constructor with
any arguments. The first location is a file named ".openframe.conf" in
the current directory, which is intended to be a local application
configuration file. If that fails, the module look at the second
location: "/etc/openframe.conf", which is intended to be a system-wide
configuration file. If both fail then the configuration is empty by
default.

When the Config object's writeConfig() is called (or the object goes
out of scope), the object attempts to make its data persistent by
writing to the two special locations above.

=head1 METHODS

=head2 new

This is the constructor.

  my $config = OpenFrame::Config->new();

=cut

##
## constructor/fileloader
##
sub new {
  my $class = shift;
  my $file = shift;

  my $self;

  if (!$file) {
    foreach my $possibility (@$CONFIGFILES) {
      if ( -e $possibility ) {
	$file = $possibility;
	last;
      }
      $file = $CONFIGFILES->[0];
    }
  }

  if ($CONFIG->{$file}) {
    if ($CONFIG->{$file}->{_isMod}) {
      $CONFIG->{$file}->writeConfig;
    }
    $self = $CONFIG->{$file};
  } else {
    if (!$file) {
      warn(sprintf("no configuration file found at %s", join(' ', @$CONFIGFILES)));
      $self = {};
    } else {
      warn("[config] attempting to open config file $file") if $OpenFrame::DEBUG;
      my $cfh = FileHandle->new( "<$file" );
      if ($cfh) {
	flock($cfh, LOCK_EX);
	local $/ = undef;
	$self = Undent( <$cfh> );
	$self->{_source} = $file;
	flock($cfh, LOCK_UN);
	$cfh->close();
      } else {
	warn("[config] could not open config file $file ($!)") if $OpenFrame::DEBUG;
	$self = {};
      }
    }

    $CONFIG->{$file} = $self;
  }


  bless $self, $class;

  if (!$self->isKey( 'VERSION' )) {
    $self->setKey( 'VERSION', $VERSION );
  }

  return $self;
}


=head2 writeConfig

The configuration file will be automatically written out when the
object goes out of scope. However, this can be forced by using the
writeConfig method:

  $config->writeConfig();

=cut

sub writeConfig {
  my $self = shift;
  return if (!$self->{_isMod});
  delete $self->{_isMod};
  my $file = $self->{source} && -w $self->{_source} ? $self->{_source} : $CONFIGFILES->[0];
  if (exists $self->{_source}) {
    delete $self->{_source};
  }
  warn("[config] attempting to write config file $file") if $OpenFrame::DEBUG;
  my $fh = FileHandle->new( ">$file" );
  if ( $fh ) {
    flock($fh, LOCK_EX);
    $fh->print( Denter( $self ) );
    flock($fh, LOCK_UN);
    $fh->close();
    $self->{_source} = $file;
    return 1;
  } else {
    warn("[config] could not write config to $file ($!)") if $OpenFrame::DEBUG;
    return undef;
  }
}


=head2 setKey

The setKey() method adds additional information to the
configuration. It takes a key and a value:

  $config->setKey('rainy', 'yes');

=cut

sub setKey {
  my $self = shift;
  my $key  = shift;
  my $val  = shift;
  $self->{_isMod} = 1;
  $self->{$key} = $val;
}


=head2 isKey

The isKey() method returns whether a key is part of the configuration,
much like the exists() function for Perl hashes. It takes a key:

  my $is_it_rainy = $config->isKey('rainy');

=cut

sub isKey {
  my $self = shift;
  return 1 if exists $self->{$_[0]};
}


=head2 getKey

The getKey() method returns information from the configuration. It
takes a key:

  my $value = $config->getKey('rainy');

=cut

sub getKey {
  my $self = shift;

  my $is = Scalar::Util::reftype($self->{$_[0]});

  if ($OpenFrame::DEBUG) {
    my $warnis = defined($is) ? $is : "[undef]";
    warn("[config] value $_[0] is a $warnis");
  }

  if (!$is) {
    return $self->{$_[0]}
  } elsif( $is eq 'HASH') {
    my %hash = %{$self->{$_[0]}};
    return {%hash};
  } elsif ($is eq 'ARRAY') {
    my @array = @{$self->{$_[0]}};
    return [@array];
  }
}


=head2 deleteKey

The deleteKey() method deletes information from the configuration. It
takes a key:

  $config->deleteKey('rainy');

=cut

sub deleteKey {
  my $self = shift;
  my $key  = shift;
  $self->{_isMod} = 1;
  delete $self->{$key};
}


=head2 sourceFile

The sourceFile() method returns the filename that the configuration is
saved in.

  my $filename = $config->sourceFile();

If called as a class method rather than an instance method it returns
or modifies the list of files that are looked at for the OpenFrame
configuration.

  OpenFrame::Config->sourceFile( "/etc/my.other.conf" );
  my $configfiles = OpenFrame::Config->sourceFile();

=cut

sub sourceFile {
  my $self = shift;
  my $val  = shift;
  if (!$val) {
    if (!ref($self)) {
      return $CONFIGFILES;
    } else {
      return $self->{_source};
    }
  } else {
    if (!ref($self)) {
      push @$CONFIGFILES, $val; 
    } else {
      $self->{_source} = $val;
      return 1;
    }
  }
}

sub DESTROY {
  my $self = shift;
  $self->writeConfig();
}

1;

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>,
Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut
