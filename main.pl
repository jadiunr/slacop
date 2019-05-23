use strict;
use warnings;
use utf8;
use Encode 'decode_utf8';
use Slack::RTM::Bot;

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

$rtm->on({subtype => 'message_deleted'}, sub {
  my $res = shift;
  my $channel = $res->{channel};
  my $prev = $res->{previous_message};

  my $sending_text = $prev->{user} ? "🔥🔥🔥 <\@$prev->{user}>'S MESSAGE HAS BEEN DELETED. 🔥🔥🔥"
                                   : $prev->{text};
  my $deleted_text = $prev->{user} ? $prev->{text}
                                   : $prev->{attachments}[0]{text};

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
      deleted_text => $deleted_text,
      thread_ts => $prev->{thread_ts}
    );
  }
});

$rtm->start_RTM(sub {
  print "RTM Start.\n";
  print "Big Brother is watching you.\n";
  while (1) {sleep 1}
});
