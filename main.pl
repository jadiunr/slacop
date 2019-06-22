use strict;
use warnings;
use utf8;
use Encode 'decode_utf8';
use Slack::RTM::Bot;
use YAML::Tiny;

use lib 'lib';
use Slack::WebAPI;

# Autoflush
$| = 1;

my $rtm = Slack::RTM::Bot->new(token => $ENV{BIGBRO_TOKEN});
my $api = Slack::WebAPI->new(
  token => $ENV{BIGBRO_TOKEN},
  username => decode_utf8($ENV{BIGBRO_USERNAME}),
  icon_url => $ENV{BIGBRO_ICON_URL}
);
my $inside_jokes = YAML::Tiny->read('./inside_jokes.yml')->[0];

# Deleted message resurrection.
$rtm->on({subtype => 'message_deleted'}, sub {
  my $res = shift;
  my $channel = $res->{channel};
  my $prev = $res->{previous_message};

  my $sending_text = $prev->{user} ? "🔥🔥🔥 <\@$prev->{user}> のメッセージが削除されました。 🔥🔥🔥"
                                   : $prev->{text};
  my $deleted_text = $prev->{user} ? [{text => $prev->{text}}]
                                   : [map {{text => $_->{text}}} @{$prev->{attachments}}];

  if ($prev->{files}) {
    my $file = $prev->{files}[0];
    
    $api->upload(
      channel => $channel,
      filetype => $file->{filetype},
      title => $file->{title},
      initial_comment => $prev->{user} ne $ENV{BIGBRO_USER_ID} ? "${sending_text}\n\n${deleted_text}"
                                                               : $deleted_text,
      file_url => $file->{url_private},
      thread_ts => $prev->{thread_ts}
    );
  } else {
    $api->post_message(
      channel => $channel,
      text => $sending_text,
      attachments => $deleted_text,
      thread_ts => $prev->{thread_ts}
    );
  }
});

# Inside joke inclusion alarm.
$rtm->on({type => 'message'}, sub {
  my $res = shift;
  my $included_jokes = [];
  my $source_text = $res->{text};

  return unless $res->{user};

  for my $excluded_word (@{$inside_jokes->{excluded}}) {
    $source_text =~ s/\n|\t| |　//g;
    $source_text =~ s/$excluded_word//g;
  }

  for my $inside_joke (@{$inside_jokes->{jokes}}) {
    push(
      @$included_jokes,
      "$inside_joke->{joke} => $inside_joke->{mean}"
    ) if $source_text =~ $inside_joke->{joke};
  }

  return unless @$included_jokes;

  $" = "\n";
  $api->post_message(
    channel => $res->{channel},
    text => "🔥 <\@$res->{user}> 内輪ネタが含まれている可能性があります。 🔥",
    attachments => [{text => "@$included_jokes"}, {text => $res->{text}}],
    thread_ts => $res->{thread_ts}
  );
});

while(1) {
  $rtm->start_RTM;
  sleep 86400;
  $rtm->stop_RTM;
}