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
    my $game = Games::WordGuess->new($config->{words});
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

  # Retrieve the game and the guess
  my $game = $self->{game};
  my $guess = $session->{system}->{parameters}->{guess};

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
