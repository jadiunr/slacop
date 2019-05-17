package Slack::WebAPI;

use strict;
use warnings;
use utf8;

use HTTP::Request::Common;
use Furl;

sub new {
  my ($class, %args) = (shift, @_);
  my $self = {};

  $self->{token} = $args{token};
  $self->{username} = $args{username};
  $self->{icon_url} = $args{icon_url};

  return bless $self, $class;
}

sub post_message {
  my ($self, %args) = @_;

  Furl->new->request(POST (
    'https://slack.com/api/chat.postMessage',
    'Content' => [
      token => $self->{token},
      channel => $args{channel},
      text => $args{text},
      username => $self->{username},
      icon_url => $self->{icon_url}
    ]
  ));
}

1;