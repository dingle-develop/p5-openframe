package Hangman::Application;

use strict;
use warnings::register;

use CGI qw(:standard :html3);
use Games::WordGuess;
use OpenFrame::Application;
use base qw (OpenFrame::Application);

our $epoints = { guess => ['guess'] };

sub default {
  my $self = shift;
  my $session = shift;
  my $request = shift;
  my $config = shift;

  # Start a new game if there isn't one already
  if (not $self->{game}) {
    my $words = $config->{words} || die "No wordlist given!";
    my $game = Games::WordGuess->new($words);
    $game->{chances} = 6;  # only give them 6 chances
    $self->{game} = $game; # save the game in our session
    $self->{guessed} = {};
  }

  $self->{message} = start_html(-title => "Hangman");
  $self->add_body($self->{game});
}

sub guess {
  my $self = shift;
  my $session = shift;
  my $request = shift;
  my $config = shift;

  # Retrieve the game and the guess
  my $game = $self->{game};
  my $guess = $request->arguments->{guess};

  if (not defined $game) {
    # We don't have a game, so set one up
    $self->default($session);
    return;
  }

  $self->{message} = start_html(-title => "Hangman");

  my $result = $game->process_guess($guess);
  $self->{guessed}->{$guess} = 1;

  if (defined($result) && $result) {
    # They got the whole word
    $self->{message} .= h1("You guessed the correct word: " .
      $game->get_answer) . hr .
      qq|<img src="/images/h| .
      (6-$game->get_chances) . qq|.gif"><br>| .
      h2("Total Score: ", $game->get_score()) . hr .
      qq|<a href="/">Keep on going</a>| .
      end_html;
    $game->init_mystery();
    $game->{chances} = 6;
    $self->{guessed} = {};
  } elsif ($game->get_chances == 0) {
    # They ran out of chances
    $self->{message} .= h1("You didn't guess the word. It was: " .
      $game->get_answer) .
      qq|<img src="/images/h| .
      (6-$game->get_chances) . qq|.gif"><br>| .
      h2("Total Score: ", $game->get_score()) . hr .
      qq|<a href="/">Try again</a>| .
      end_html;
    # Remove the game from our session
    delete $self->{game};
  } else {
    # Show the results of the guess
    $self->add_body($game);
  }
}

# Print the HTML showing the current status
sub add_body {
  my $self = shift;
  my $game = shift;

  $self->{message} .= qq|<img src="/images/h| .
    (6-$game->get_chances) . qq|.gif"><br>|;
  $self->{message} .= h1($game->in_progress) . hr .
    h2("Chances: " . $game->get_chances) .
      h2("Score: ". $game->get_score()) . hr;
  $self->{message} .= h2("Your guess?"). p;
  foreach ('A'..'Z') {
    if (not exists $self->{guessed}->{$_}) {
      $self->{message} .= qq|<a href="/?guess=$_">$_</a> |;
    } else {
      $self->{message} .= qq|$_ |;
    }
  }
  $self->{message} .= end_html;
}

1;

__END__

=head1 NAME

Hangman::Application - A module containing the hangman logic

=head1 DESCRIPTION

C<Hangman::Application> is part of the simple hangman web
application. The module contains all the logic and presentation for
Hangman.

Note that the application has two main entry points: the default() and
the guess() subroutines. The C<$epoint> hash at the beginning of the
module sets up the call to guess() if a "guess" parameter is passed in
the request. Otherwise, default() is called.

Each entry point is given itself, the session, an abstract request,
and per-application configuration. They then contain application logic
- note that we store a Games::WordGuess object inside C<$self> and
that this is magically persistent between calls.

This code is small and dirty as the output is generated inline using
the CGI module and the add_body() method. Note that the output is
stored inside C<$self> to be passed on to C<Hangman::Generator>.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
