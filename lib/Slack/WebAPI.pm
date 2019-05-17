package Slack::WebAPI;

use strict;
use warnings;
use utf8;
use Encode 'encode_utf8';
use File::Temp 'tempfile';

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

  eval {
    Furl->new->request(POST (
      'https://slack.com/api/chat.postMessage',
      'Content' => [
        token => $self->{token},
        channel => $args{channel},
        text => $args{text},
        username => $self->{username},
        icon_url => $self->{icon_url},
        thread_ts => $args{thread_ts},
        reply_broadcast => 'true'
      ]
    ));
  };

  warn "WARNING: $@" if $@;
}

sub upload {
  my ($self, %args) = @_;
  my $file = Furl->new->get($args{file_url}, ['Authorization' => "Bearer ".$self->{token}]);

  my ($tmpfh, $tmpfile) = tempfile(UNLINK => 1);
  print $tmpfh $file->content;
  close $tmpfh;

  eval { 
    Furl->new->request(POST (
      'https://slack.com/api/files.upload',
      'Content-Type' => 'form-data',
      'Content' => [
        token => $self->{token},
        channels => encode_utf8 $args{channel},
        filetype => $args{filetype},
        title => encode_utf8 $args{title},
        initial_comment => encode_utf8 $args{initial_comment},
        thread_ts => $args{thread_ts},
        file => [$tmpfile]
      ]
    ));
  };

  warn "WARNING: $@" if $@;
  unlink $tmpfile;
}

1;