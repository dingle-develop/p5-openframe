package Hangman::Application;

use strict;
use warnings::register;

use Games::WordGuess;
use OpenFrame::Application;
use base qw (OpenFrame::Application);

our $epoints = { guess => ['guess'] };

sub default {
  my $self = shift;
  my $session = shift;
  my $request = shift;
  my $config = shift;

  delete $self->{message};

  # Start a new game if there isn't one already
  if (not $self->{game}) {
    my $game = Games::WordGuess->new($config->{words});
    $game->{chances} = 6;  # only give them 6 chances
    $self->{game} = $game; # save the game in our session
    $self->{guessed} = {};
  }
}

sub guess {
  my $self = shift;
  my $session = shift;
  delete $self->{message};

  # Retrieve the game and the guess
  my $game = $self->{game};
  my $guess = $session->{system}->{parameters}->{guess};

  if (not defined $game) {
    # We don't have a game, so set one up
    $self->default($session);
    return;
  }

  my $result = $game->process_guess($guess);
  $self->{guessed}->{$guess} = 1;

  if (defined($result) && $result) {
    # They got the whole word
    $self->{message} = "You guessed the correct word: ".
      $game->get_answer;
    $game->init_mystery();
    $game->{chances} = 6;
    $self->{guessed} = {};
  } elsif ($game->get_chances == 0) {
    # They ran out of chances
    $self->{message} = "You didn't guess the word. It was: " .
      $game->get_answer;
    $self->{finalscore} = $game->get_score();
    # Remove the game from our session
    delete $self->{game};
  } else {
    # Show the results of the guess
  }
}

1;
